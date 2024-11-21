//
//  ApiService.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation

protocol APIServiceProtocol {
    func Get<T: Decodable>(_ path: String, completion: @escaping (Result<T, Error>) -> Void)
    func Post<T: Encodable>(_ path: String, data: T, completion: @escaping (Result<T, Error>) -> Void) async
    func Put<T: Encodable>(_ path: String, data: T, completion: @escaping (Result<T, Error>) -> Void) async
    func Delete<T: Encodable>(_ path: String, data: T, completion: @escaping (Result<T, Error>) -> Void) async
}

class UrlComponent {
    var path: String
    let baseUrl = "http://localhost:3000/api/"
    
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
                completion(.failure(error!))
                return
            }
        
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
        
        task.resume()
    }
    
    func Post<T>(_ path: String, data: T, completion: @escaping (Result<T, any Error>) -> Void) where T : Encodable {
        
    }
    
    func Put<T>(_ path: String, data: T, completion: @escaping (Result<T, any Error>) -> Void) where T : Encodable {
    
    }
    
    func Delete<T>(_ path: String, data: T, completion: @escaping (Result<T, any Error>) -> Void) where T : Encodable {
        
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case interalError
}
