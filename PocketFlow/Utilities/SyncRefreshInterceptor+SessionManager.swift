//
//  SyncRefreshInterceptot+SessionManager.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 08/12/2024.
//

import Foundation

// MARK: -- Locks and sync variable
private let requestLock = NSLock()
private let isRefreshingLock = NSLock()

private var isRefreshing = false

// **Atomically** check if there's a refresh request in flight, if no, update
// `isRefreshing` to true and return true, otherwise return false
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
            
            guard httpResponse.statusCode == 401 else {
                return (data, response)
            }
            
            // Request failed with 401 and needs handling refresh (or no refresh)
            var responseData: Data?
            var urlResponse: URLResponse?
            
            self.handleUnauthorizedRequest(urlRequest) { data, response, _ in
                responseData = data
                urlResponse = response
            }
            
            return (responseData, urlResponse)
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
            completion(nil, nil, NetworkError.refreshFailed)
        }

        pendingRequests.removeAll()
    }
    
    private func syncRefreshToken() -> Bool {
        requestLock.lock()
        
        // Executes just before the func is closed
        defer {
            atomicSetRefreshing(newVal: false)
            requestLock.unlock()
        }
        
        let url = UrlComponent(path: "auth/refresh").url
        let refreshToken = RefreshTokenRequest(refresh_token: Auth.shared.getRefreshToken() ?? "")
        let body = try? JSONEncoder().encode(refreshToken)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
    
        return false
    }
}

struct RefreshTokenRequest: Codable {
    let refresh_token: String
}

extension URLSession {
    func synchronousData(with request: URLRequest) -> (Data?, URLResponse?) {
        var data: Data?
        var response: URLResponse?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: request) { (result, urlResponse, _) in
            data = result
            response = urlResponse

            _ = semaphore.signal()
        }

        dataTask.resume()
        
        _ = semaphore.wait(timeout: DispatchTime.now() + .seconds(6))

        return (data, response)
    }
}
