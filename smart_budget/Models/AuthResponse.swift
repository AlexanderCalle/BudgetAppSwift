//
//  AuthResponse.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import Foundation

struct AuthResponse: Decodable {
    let user: User
    let session: Session
        
    struct User: Decodable {
        let id: String
    }
    
    struct Session: Decodable {
        let accessToken: String
        let refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
        }
    }
}
