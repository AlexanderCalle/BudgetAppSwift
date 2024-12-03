//
//  Auth.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import Foundation
import KeychainSwift

class Auth: ObservableObject {
    
    struct Credentials {
        var accessToken: String?
        var refreshToken: String?
    }
    
    enum KeychainKey: String {
        case accessToken
        case refreshToken
    }
    
    static let shared = Auth()
    private let keychain = KeychainSwift()
    
    @Published var loggedIn: Bool = false
    @Published var isNewUser: Bool = true
    
    private init() {
        loggedIn = hasAccesToken()
    }
    
    func getCredentials() -> Credentials {
        return Credentials(
            accessToken: keychain.get(KeychainKey.accessToken.rawValue),
            refreshToken: keychain.get(KeychainKey.refreshToken.rawValue)
        )
    }
    
    func setCredentials(accesToken: String, refreshToken: String) {
        keychain.set(accesToken, forKey: KeychainKey.accessToken.rawValue)
        keychain.set(refreshToken, forKey: KeychainKey.refreshToken.rawValue)
        
        loggedIn = true
    }
    
    func setNewUser(isNewUser: Bool) {
        self.isNewUser = isNewUser
    }
    
    func hasAccesToken() -> Bool {
        return getCredentials().accessToken != nil
    }
    
    func getAccessToken() -> String? {
        return getCredentials().accessToken
    }

    func getRefreshToken() -> String? {
        return getCredentials().refreshToken
    }
    
    func logout() {
        keychain.clear()
        
        loggedIn = false
    }
    
}
