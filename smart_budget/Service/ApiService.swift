//
//  ApiService.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation

protocol APIServiceProtocol {
    func Get<T: Codable>(_ path: String, completion: @escaping (Result<T, Error>) -> Void)
    func Post<T: Codable>(_ path: String, body: T, completion: @escaping (Result<T, Error>) -> Void) async
    func Put<T: Codable>(_ path: String, body: T, completion: @escaping (Result<T, Error>) -> Void) async
    func Delete(_ path: String, completion: @escaping (Result<Bool, Error>) -> Void) async
}

class UrlComponent {
    var path: String
   // let baseUrl = "https://budget-api-psi.vercel.app/api/"
    //let baseUrl = "http://localhost:3000/api/"
    let baseUrl = "http://192.168.68.127:3000/api/"
    
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

private let sessionManager: URLSession = {
    let urlSessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
    return URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: nil)
}()


struct ApiService: APIServiceProtocol {
    
    private func GuardResponseError<T>(_ error: Error) -> Result<T, Error> where T: Codable{
        if let error = error as? URLError {
            switch error.code {
            case .notConnectedToInternet:
                print("No internet connection")
                return.failure(NetworkError.noInternet)
            case .timedOut:
                print("The request timed out")
                return.failure(NetworkError.timeout)
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
    
    func Get<T>(_ path: String, completion: @escaping (Result<T, any Error>) -> Void) where T : Codable {
        let url = UrlComponent(path: path).url
            
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
    
            guard error == nil else {
                // Network error mapper for error handling
                completion(GuardResponseError(error!))
                return
            }
                   
            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    // Http response code mapper for error handling
                    completion(HttpErrorResponseMapper(response, data: data))
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let formatter = DateFormatter.iso8601WithMilliseconds
                        decoder.dateDecodingStrategy = .formatted(formatter)
                        
                        let response = try decoder.decode(T.self, from: data!)
                        completion(.success(response))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func Post<T>(_ path: String, body: T, completion: @escaping (Result<T, any Error>) -> Void) where T : Codable {
        let url = UrlComponent(path: path).url
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? encoder.encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
    
            guard error == nil else {
                // Network error mapper for error handling
                completion(GuardResponseError(error!))
                return
            }
                   
            // TODO: Mapper for errors
            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    completion(HttpErrorResponseMapper(response, data: data))
                } else {
                    completion(.success(body))
                }
            }
        }
        
        task.resume()
        
    }
    
    func Put<T>(_ path: String, body: T, completion: @escaping (Result<T, any Error>) -> Void) where T : Codable {
        let url = UrlComponent(path: path).url
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try? encoder.encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
    
            guard error == nil else {
                // Network error mapper for error handling
                completion(GuardResponseError(error!))
                return
            }
                   
            // TODO: Mapper for errors
            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    completion(HttpErrorResponseMapper(response, data: data))
                } else {
                    completion(.success(body))
                }
            }
        }
        
        task.resume()
    }
    
    func Delete(_ path: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        let url = UrlComponent(path: path).url
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                // Network error mapper for error handling
                completion(GuardResponseError(error!))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    // Http response code mapper for error handling
                    completion(HttpErrorResponseMapper(response, data: data))
                } else {
                    completion(.success(true))
                }
            }
        }
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noInternet
    case timeout
    case unReachable(String)
    case interalError
}

enum ApiError: Error {
    case notFound(DecodedMessage?)
    case badRequest(DecodedMessage?)
    case forbidden
    case unauthorized
    case internalError
    case unknown(Int?, String?)
}
