//
//  SigninUser$.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import Foundation

struct SigninUser: Codable {
    let email: String
    let password: String
}

struct CreateUser: Codable {
    let email: String
    let password: String
    let firstname: String
    let lastname: String
}
