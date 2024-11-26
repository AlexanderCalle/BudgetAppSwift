//
//  ApiService.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation

protocol APIServiceProtocol {
    func Get<T: Decodable>(_ path: String, completion: @escaping (Result<T, Error>) -> Void)
    func Post<T: Codable>(_ path: String, body: T, completion: @escaping (Result<T, Error>) -> Void) async
    func Put<T: Encodable>(_ path: String, data: T, completion: @escaping (Result<T, Error>) -> Void) async
    func Delete<T: Encodable>(_ path: String, data: T, completion: @escaping (Result<T, Error>) -> Void) async
}

class UrlComponent {
    var path: String
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
    func Get<T>(_ path: String, completion: @escaping (Result<T, any Error>) -> Void) where T : Decodable {
        let url = UrlComponent(path: path).url
            
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
    
            guard error == nil else {
                
                if let error = error as? URLError {
                    switch error.code {
                    case .notConnectedToInternet:
                        print("No internet connection")
                        completion(.failure(NetworkError.noInternet))
                    case .timedOut:
                        print("The request timed out")
                        completion(.failure(NetworkError.timeout))
                    case .cannotFindHost, .cannotConnectToHost:
                        print("Cannot reach the server")
                        completion(.failure(NetworkError.unReachable("Server cannot be reached")))
                    default:
                        print("Other error: \(error.localizedDescription)")
                    }
                } else {
                    completion(.failure(error!))
                }
                return
            }
                   
            // TODO: Mapper for errors
            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
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
                            completion(.failure(ApiError.badRequest(decoderError)))
                        case 401:
                            completion(.failure(ApiError.unauthorized))
                        case 403:
                            completion(.failure(ApiError.forbidden))
                        case 404:
                            completion(.failure(ApiError.notFound(decoderError)))
                        case 500:
                            completion(.failure(ApiError.internalError))
                        default :
                            completion(.failure(ApiError.unknown(response.statusCode, response.description)))
                        }
                        return
                    } catch {
                        completion(.failure(error))
                    }
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
                
                if let error = error as? URLError {
                    switch error.code {
                    case .notConnectedToInternet:
                        print("No internet connection")
                        completion(.failure(NetworkError.noInternet))
                    case .timedOut:
                        print("The request timed out")
                        completion(.failure(NetworkError.timeout))
                    case .cannotFindHost, .cannotConnectToHost:
                        print("Cannot reach the server")
                        completion(.failure(NetworkError.unReachable("Server cannot be reached")))
                    default:
                        print("Other error: \(error.localizedDescription)")
                    }
                } else {
                    completion(.failure(error!))
                }
                return
            }
                   
            // TODO: Mapper for errors
            if let response = response as? HTTPURLResponse {
                let decoder = JSONDecoder()

                if !(200...299).contains(response.statusCode) {
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
                            completion(.failure(ApiError.badRequest(decoderError)))
                        case 401:
                            completion(.failure(ApiError.unauthorized))
                        case 403:
                            completion(.failure(ApiError.forbidden))
                        case 404:
                            completion(.failure(ApiError.notFound(decoderError)))
                        case 500:
                            completion(.failure(ApiError.internalError))
                        default :
                            completion(.failure(ApiError.unknown(response.statusCode, response.description)))
                        }
                        return
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.success(body))
                }
            }
        }
        
        task.resume()
        
    }
    
    func Put<T>(_ path: String, data: T, completion: @escaping (Result<T, any Error>) -> Void) where T : Encodable {
    
    }
    
    func Delete<T>(_ path: String, data: T, completion: @escaping (Result<T, any Error>) -> Void) where T : Encodable {
        
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
