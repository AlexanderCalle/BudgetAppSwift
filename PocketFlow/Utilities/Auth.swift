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
        case userData
    }
    
    static let shared = Auth()
    private let keychain = KeychainSwift()
    
    @Published var loggedIn: Bool = false
    @Published var isNewUser: Bool = false
    @Published var isRefreshingToken = false
    
    private init() {
        loggedIn = hasAccesToken()
    }
    
    func getCredentials() -> Credentials {
        return Credentials(
            accessToken: keychain.get(KeychainKey.accessToken.rawValue),
            refreshToken: keychain.get(KeychainKey.refreshToken.rawValue)
        )
    }
    
    func setCredentials(accesToken: String, refreshToken: String, isNewUser: Bool = false) {
        setNewUser(isNewUser: isNewUser)
        
        keychain.set(accesToken, forKey: KeychainKey.accessToken.rawValue)
        keychain.set(refreshToken, forKey: KeychainKey.refreshToken.rawValue)
        
        self.loggedIn = true
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
    
    func setIsRefreshingToken(_ isRefreshingToken: Bool) {
        self.isRefreshingToken = isRefreshingToken
    }
    
    func getUser() throws -> User? {
        guard let userData = keychain.getData(KeychainKey.userData.rawValue) else { return nil }
        return try JSONDecoder().decode(User.self, from: userData)
    }
    
    func setUser(_ user: User) throws {
        keychain.set(try JSONEncoder().encode(user), forKey: KeychainKey.userData.rawValue)
    }
    
    func logout() {
        keychain.clear()
        loggedIn = false
    }
    
}
