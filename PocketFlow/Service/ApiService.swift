//
//  ApiService.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation

protocol APIServiceProtocol {
    func get<T: Codable>(_ path: String, completion: @escaping (Result<T, Error>) -> Void)
    func post<T: Codable>(_ path: String, body: T, completion: @escaping (Result<T, Error>) -> Void) async
    func put<T: Codable>(_ path: String, body: T, completion: @escaping (Result<T, Error>) -> Void) async
    func delete(_ path: String, completion: @escaping (Result<Bool, Error>) -> Void) async
    func auth<T: Codable>(_ path: String, body: T, completion: @escaping (Result<Bool, Error>) -> Void) async
}

class UrlComponent {
    var path: String
    let baseUrl = ProcessInfo.processInfo.environment["API_URL"] ?? "https://budget-api-psi.vercel.app/api/"
    
    
    var url: URL {
        let urlString = baseUrl.appending(path)
        
        guard let composedUrl = URL(string: urlString) else {
            fatalError("Could not create URL from \(urlString)")
        }
        
        return composedUrl
    }
    
    init(path: String) {
        self.path = path
    }
}

private let sessionManager = SessionManager()


struct ApiService: APIServiceProtocol {    
    // MARK: - Erorr mappers
    private func GuardResponseError<T>(_ error: Error) -> Result<T, Error> where T: Codable{
        if let error = error as? URLError {
            switch error.code {
            case .notConnectedToInternet:
                print("No internet connection")
                return .failure(NetworkError.noInternet)
            case .timedOut:
                print("The request timed out")
                return .failure(NetworkError.timeout)
            case .cannotFindHost, .cannotConnectToHost:
                print("Cannot reach the server")
                return .failure(NetworkError.unReachable("Server cannot be reached"))
            default:
                print("Other error: \(error.localizedDescription)")
            }
        }
        return .failure(error)
    }
    
    private func HttpErrorResponseMapper<T>(_ response: HTTPURLResponse, data: Data?) -> Result<T, Error> where T: Codable {
        do {
            let decoder = JSONDecoder()
            var decoderError: DecodedMessage?
            if let data = data {
                if let json = String(data: data, encoding: String.Encoding.utf8) {
                    if let json = json.data(using: .utf8) {
                        decoderError = try decoder.decode(DecodedMessage.self, from: json)
                    }
                }
            }
            switch response.statusCode {
                case 400:
                    return .failure(ApiError.badRequest(decoderError))
                case 401:
                    return .failure(ApiError.unauthorized)
                case 403:
                    return .failure(ApiError.forbidden)
                case 404:
                    return .failure(ApiError.notFound(decoderError))
                case 500:
                    return .failure(ApiError.internalError)
                default :
                    return .failure(ApiError.unknown(response.statusCode, response.description))
            }
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - HTTP methods
    func get<T>(_ path: String, completion: @escaping (Result<T, any Error>) -> Void) where T : Codable {
        let url = UrlComponent(path: path).url
        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy

        Task.init {
            do {
                let (data, response) = try await sessionManager.request(with: request)
                // Guards agains non Http responses
                guard let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(NetworkError.interalError))
                }
                
                // Checks of there is data
                guard let data = data else {
                    return completion(.failure(NetworkError.interalError))
                }
                
                // Checks if response is successfull
                // Otherwise return with corresponding Http Error message
                guard (200...299).contains(httpResponse.statusCode) else {
                    return completion(HttpErrorResponseMapper(httpResponse, data: data))
                }
 
                do {
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter.iso8601WithMilliseconds
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            } catch {
                completion(GuardResponseError(error))
            }
        }
    }
    
    func post<T>(_ path: String, body: T, completion: @escaping (Result<T, any Error>) -> Void) where T : Codable {
        let url = UrlComponent(path: path).url
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.httpBody = try? encoder.encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        Task.init {
            do {
                let (data, response) = try await sessionManager.request(with: request)
                    
                guard let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(NetworkError.interalError))
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return completion(HttpErrorResponseMapper(httpResponse, data: data))
                }
                
                completion(.success(body))
            } catch {
                completion(GuardResponseError(error))
            }
        }
        
    }
    
    func put<T>(_ path: String, body: T, completion: @escaping (Result<T, any Error>) -> Void) where T : Codable {
        let url = UrlComponent(path: path).url
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try? encoder.encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        Task.init {
            do {
                let (data, response) = try await sessionManager.request(with: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(NetworkError.interalError))
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return completion(HttpErrorResponseMapper(httpResponse, data: data))
                }
                
                completion(.success(body))
            } catch {
                completion(GuardResponseError(error))
            }
        }
    }
    
    func delete(_ path: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        let url = UrlComponent(path: path).url
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        Task.init {
            do {
                let (data, response) = try await sessionManager.request(with: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkError.interalError))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return completion(HttpErrorResponseMapper(httpResponse, data: data))
                }
                
                completion(.success(true))
            } catch {
                completion(GuardResponseError(error))
            }
        }
    }
    
    // MARK: -- Authentication methods
    func auth<T>(_ path: String, body: T, completion: @escaping (Result<Bool, any Error>) -> Void) where T : Codable {
        let url = UrlComponent(path: path).url
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.httpBody = try? JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        Task.init {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                        
                guard let response = response as? HTTPURLResponse else { return completion(.failure(NetworkError.interalError)) }
                       
                if !(200...299).contains(response.statusCode) {
                    if (response.statusCode == 400) {
                        do {
                            let decoderError = try JSONDecoder().decode(AuthErrorResponse.self, from: data)
                            completion(.failure(ApiError.authError(decoderError)))
                        } catch {
                            completion(.failure(NetworkError.interalError))
                        }
                    } else {
                        completion(HttpErrorResponseMapper(response, data: data))
                    }
                } else {
                    do {
                        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                        Auth.shared.setCredentials(accesToken: authResponse.session.accessToken, refreshToken: authResponse.session.refreshToken, isNewUser: path.contains("signup"))
                        completion(.success(true))
                    } catch {
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(GuardResponseError(error))
            }
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noInternet
    case timeout
    case refreshFailed
    case unReachable(String)
    case interalError
    
    var errorMessage: String? {
        switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noInternet:
                return "No Internet Connection"
            case .timeout:
                return "Timeout"
            case .refreshFailed:
                return "Refresh Authentication Failed"
            case .unReachable(let message):
                return message
            case .interalError:
                return "Internal Error"
        }
    }
}

enum ApiError: Error {
    case notFound(DecodedMessage?)
    case badRequest(DecodedMessage?)
    case authError(AuthErrorResponse?)
    case forbidden
    case unauthorized
    case internalError
    case unknown(Int?, String?)
    
    func getErrorMessage() -> String? {
        switch self {
        case .notFound(let message):
            return message?.errorMessage() ?? "Not Found"
        case .badRequest(let message):
            return message?.errorMessage() ?? "Bad Request"
        case .authError(let message):
            return message?.errorMessage() ?? "Unauthorized"
        case .forbidden:
            return "Forbidden"
        case .unauthorized:
            return "Unauthorized"
        case .internalError:
            return "Internal Error"
        case .unknown(_, let message):
            return message
        }
    }
}


extension URLRequest {
    mutating func setAuthorizationHeader(with token: String) {
        self.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
