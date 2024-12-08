//
//  SyncRefreshInterceptor.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 08/12/2024.
//

import Foundation
import Alamofire

// MARK: -- Locks and sync variabl
private let requestLock = NSLock()
private let isRefreshingLock = NSLock()

private var isRefreshing = false

// **Atomically** check if there's a refresh request in flight, if no, update
// `isRefreshing` to true and return true, otherwise return false
// Essentially we are using a lock/mutex to implement compare-and-swap
private func atomicCheckAndSetRefreshing() -> Bool {
    isRefreshingLock.lock(); defer { isRefreshingLock.unlock() }
    
    if !isRefreshing {
        isRefreshing = true
        
        return true
    }
    
    return false
}

private func atomicSetRefreshing(newVal: Bool) {
    isRefreshingLock.lock(); defer { isRefreshingLock.unlock() }
    
    isRefreshing = newVal
}

class SyncRefreshInterceptor: RequestInterceptor {
    private var accessToken: String {
        return Auth.shared.getAccessToken() ?? ""
    }
    
    private var refreshToken: String {
        return Auth.shared.getRefreshToken() ?? ""
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        if (urlRequest.url?.absoluteString) != nil {
            var urlRequest = urlRequest
            
            if !accessToken.isEmpty {
                urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            
            return completion(.success(urlRequest))
        }
        
        return completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            if atomicCheckAndSetRefreshing() {
                // The conditional expression 'atomicCheckAndSetRefreshing()'
                // atomically returns *true* when `isRefreshing` *was*
                // false, when that happens we know the current running thread
                // has an exclusive hold over the right to send out the refresh token request
                
                //  Perform token refresh and blocking wait for the result to come back
                let refreshSuccessful = syncRefreshToken()
                if refreshSuccessful {
                    completion(.retry)
                } else {
                    // Bubble up the original API request error (401) to the
                    // its completion closure
                    completion(.doNotRetryWithError(error))
                }
            } else {
                // the conitional fails, at this point we know `isRefreshing`
                // is false, and there's must be a refresh request in flight.
                // We don't need to send out another refresh request.
                
                // Here we re-queue or *retry* the original request with a delay
                // hoping that by the time the delay ends, a new access token
                // will become available.
                //
                // We need to retry the original request with a delay for a
                // reasonable amount of time, the delay should be *short* enough
                // that it doesn't degrade performance, but also long enough
                // that a refresh request should hopefully come back with a
                // result before it ends.
                //
                // IMPORTANT: The latter is **important**, because it's possible that
                // the delay is too short, the API request with the
                // not-yet-updated-access-token might be retried prematurely before the
                // previous refresh request comes back, resulting in another redundant
                // refresh request (should be harmless though).
                //
                // This delay and synchronised refresh request call give us the
                // **debouncing** behaviour whereby only one refresh request
                // gets triggered regardless how many API requests with 401
                // happen beforehand.

                completion(.retryWithDelay(2))
            }
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
    
    private func syncRefreshToken() -> Bool {
        // Perform a synchronised and synchronous token refresh request.
        
        // It needs to be both **synchronised** (i.e. no other threads can send
        // it while it's in flight), and **synchronous** (i.e. the interceptor
        // chain can not proceed without it comes back with a result)
        requestLock.lock()
        
        defer {
            atomicSetRefreshing(newVal: false)
            requestLock.unlock()
        }
        
        let url = UrlComponent(path: "auth/refresh?refresh_token=\(Auth.shared.getRefreshToken() ?? "")").url
        if let request = try? URLRequest(url: url, method: .get) {
            let (data, response) = URLSession.shared.synchronousData(with: request)
            if let data = data {
                let decodedResponse = try? JSONDecoder().decode(AuthResponse.self, from: data)
                if let session = decodedResponse?.session {
                    let refreshToken = session.refreshToken
                    let accessToken = session.accessToken
                    
                    Auth.shared.setCredentials(accesToken: accessToken, refreshToken: refreshToken)
                    return true
                }
            }
        }
        return false
    }
}

class SessionManager: NSObject, URLSessionDelegate {
    private var session: URLSession!
    private var pendingRequests: [(URLRequest, (Data?, URLResponse?, Error?) -> Void)] = []
    
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024, // 20 MB
          diskCapacity: 100 * 1024 * 1024, // 100 MB
          diskPath: nil)
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func makeRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var modifiedRequest = request
        let token = Auth.shared.getAccessToken() ?? ""
        modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        session.dataTask(with: modifiedRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(data, response, error)
            }
            
            if httpResponse.statusCode == 401 {
                self.handleUnauthorizedRequest(request, completion: completion)
            } else {
                completion(data, response, error)
            }
        }.resume()
    }
    
    func request(with urlRequest: URLRequest) async throws -> (Data?, URLResponse?) {
        // Add token to the request
        var modifiedRequest = urlRequest
        let token = Auth.shared.getAccessToken() ?? ""
        modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: modifiedRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                return (data, response)
            }
            
            if httpResponse.statusCode == 401 {
                var responseData: Data?
                var urlResponse: URLResponse?
                self.handleUnauthorizedRequest(urlRequest) { data, response, _ in
                    responseData = data
                    urlResponse = response
                }
                return (responseData, urlResponse)
            }
            return (data, response)
        } catch {
            throw error
        }
    }
    
    func authenticationRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        session.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
    
    private func handleUnauthorizedRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        pendingRequests.append((request, completion))
        
        guard atomicCheckAndSetRefreshing() else { return }
        
        let refreshSuccessful = syncRefreshToken()
        if refreshSuccessful {
            self.retryPendingRequests()
        } else {
            // Bubble up the original API request error (401) to the
            // its completion closure
            self.failPendingRequests()
        }
    }
    
    private func retryPendingRequests() {
        let token = Auth.shared.getAccessToken() ?? ""

        for (originalRequest, completion) in pendingRequests {
            var modifiedRequest = originalRequest
            modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            session.dataTask(with: modifiedRequest, completionHandler: completion).resume()
        }

        pendingRequests.removeAll()
    }

    private func failPendingRequests() {
        for (_, completion) in pendingRequests {
            completion(nil, nil, NSError(domain: "TokenRefreshError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh token"]))
        }

        pendingRequests.removeAll()
    }
    
    private func syncRefreshToken() -> Bool {
        // Perform a synchronised and synchronous token refresh request.
        
        // It needs to be both **synchronised** (i.e. no other threads can send
        // it while it's in flight), and **synchronous** (i.e. the interceptor
        // chain can not proceed without it comes back with a result)
        requestLock.lock()
        
        defer {
            atomicSetRefreshing(newVal: false)
            requestLock.unlock()
        }
        
        let url = UrlComponent(path: "auth/refresh?refresh_token=\(Auth.shared.getRefreshToken() ?? "")").url
        if let request = try? URLRequest(url: url, method: .get) {
            let (data, _) = session.synchronousData(with: request)
            if let data = data {
                let decodedResponse = try? JSONDecoder().decode(AuthResponse.self, from: data)
                if let session = decodedResponse?.session {
                    let refreshToken = session.refreshToken
                    let accessToken = session.accessToken
                    
                    Auth.shared.setCredentials(accesToken: accessToken, refreshToken: refreshToken)
                    return true
                }
            }
        }
        return false
    }
}

extension URLSession {
    func synchronousData(with request: URLRequest) -> (Data?, URLResponse?) {
        var data: Data?
        var response: URLResponse?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: request) { (result, urlResponse, _) in
            // IMPORTANT: This closure must be executed in a thread that's
            // different from the calling thread, otherwise it will deadlock,
            // because at this point the calling thread is waiting for the
            // semaphore to be signaled.
            //
            // If the `dataTask` for some reason tries to schedule the closure
            // to execute in the calling thread, it will wait forever. Because
            // the calling thread is also waiting for this closure to run,
            // hence a deadlock.
            //
            // So here we rely on an implicit assumption that `dataTask` willal
            // always call the closure in a different thread...

            data = result
            response = urlResponse

            _ = semaphore.signal()
        }

        dataTask.resume()
        // Wait for the dataTask to call the above closure to signal the
        // completion of the token refresh request.
        //
        // Have a timeout to avoid deadlocks when the aforementioned _implicit_
        // assumption (i.e. the closure will always run in a separate thread)
        // doesn't hold.
        _ = semaphore.wait(timeout: DispatchTime.now() + .seconds(6))

        return (data, response)
    }
}
