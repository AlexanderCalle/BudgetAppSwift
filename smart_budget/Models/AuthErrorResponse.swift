//
//  AuthErrorResponse.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 07/12/2024.
//

import Foundation

struct AuthErrorResponse: Decodable {
    let name: String
    let status: Int
    let code: AuthErrorCode
    
    func errorMessage() -> String {
        return "Auth Error: \(code.rawValue), \(name), \(status)"
    }
}

enum AuthErrorCode: String, Codable {
    case userAlreadyExists = "user_already_exists"
    case invalidCredentials = "invalid_credentials"
}
