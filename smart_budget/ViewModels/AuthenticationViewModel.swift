//
//  AuthenticationViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    
    @Published var loginState: ViewState<Bool> = .idle
    @Published var validationErrors: [ValidationError] = []
    
    func errors(forKey key: String) -> [ValidationError] {
        validationErrors.filter { $0.key == key }
    }
    
    let api = ApiService()
    
    func login(email: String, password: String) {
        
        guard validate(email: email, password: password) else { return }
        
        print("Logging in...")
        loginState = .loading
        let signinUser: SigninUser = .init(email: email, password: password)
        
        api.login("auth/signin", body: signinUser) { [weak self] (result: Result<Bool, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.validationErrors.removeAll()
                    self?.loginState = .success(true)
                case .failure(let error):
                    print("Login error: \(error.localizedDescription)")
                    self?.loginState = .failure(error)
                }
            }
        }
    }
    
    private func validate(email: String, password: String) -> Bool {
        validationErrors.removeAll()
        if email.isEmpty {
            validationErrors.append(.init(key: "emaiil", message: "Email is required"))
        }
        
        if !validateEmail(email) {
            validationErrors.append(.init(key: "email", message: "Invalid email format"))
        }
            
        if password.isEmpty {
            validationErrors.append(.init(key: "password", message: "Password is required"))
        }
        
        if password.count < 8 {
            let message = "Password must be at least 8 characters long"
            validationErrors.append(.init(key: "password", message: message))
        }
        
        return validationErrors.count == 0
    }
    
    
    private func validateEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}
