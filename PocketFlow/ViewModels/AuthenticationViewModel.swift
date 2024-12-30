//
//  AuthenticationViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    
    // MARK: - FORM STATE
    @Published var loginState: ViewState<Bool> = .idle
    @Published var SignupState: ViewState<Bool> = .idle
    @Published var validationErrors: [ValidationError] = []
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstname: String = ""
    @Published var lastname: String = ""
    
    // MARK: - RESET STATE
    @Published var resetState: ViewState<Bool> = .idle
    @Published var resetEmail: String = ""
    
    func errors(forKey key: String) -> [ValidationError] {
        validationErrors.filter { $0.key == key }
    }
    
    let api = ApiService()
    
    func login() {
        guard validateLogin() else { return }
        
        print("Logging in...")
        loginState = .loading
        let signinUser: SigninUser = .init(email: email, password: password)
        
        api.auth("auth/signin", body: signinUser) { [weak self] (result: Result<Bool, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.validationErrors.removeAll()
                    self?.loginState = .success(true)
                    Auth.shared.isNewUser = false
                    self?.fetchProfile()
                case .failure(let error):
                    print("Login error: \(error.localizedDescription)")
                    self?.loginState = .failure(error)
                }
            }
        }
    }
    
    func signup() {
        guard validateSignup() else { return }
        
        SignupState = .loading
        
        let signupUser: CreateUser = .init(email: email, password: password, firstname: firstname, lastname: lastname)
        
        api.auth("auth/signup", body: signupUser) { [weak self] (result: Result<Bool, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.SignupState = .success(true)
                    try? Auth.shared.setUser(User(email: self?.email ?? "", firstname: self?.firstname ?? "", lastname: self?.lastname ?? ""))
                case .failure(let error):
                    self?.SignupState = .failure(error)
                }
            }
        }
    }
    
    struct RecoveryBody: Codable {
        let email: String
    }
    
    func resetPassword() {
        validationErrors.removeAll()
        
        guard validateEmail(email) else {
            validationErrors.append(.init(key: "email", message: "Invalid email format"))
            return
        }
        
        resetState = .loading
        let body = RecoveryBody(email: email)
        
        api.post("auth/recovery", body: body) { [weak self] (result: Result<RecoveryBody, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.resetState = .success(true)
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        self?.resetState = .failure(networkError)
                    }
                    if let apiError = error as? ApiError {
                        if case .badRequest(let decodedMessage) = apiError {
                            switch(decodedMessage) {
                            case .detailed(let details, _, _):
                                details.forEach { detail in
                                    self?.validationErrors.append(ValidationError(key: detail.property, message: detail.message))
                                }
                                self?.resetState = .failure(apiError)
                            default:
                                self?.resetState = .failure(apiError)
                            }
                        } else {
                            self?.resetState = .failure(apiError)
                        }
                    } else {
                        self?.resetState = .failure(error)
                    }
                }
            }
        }
    }
    
    func fetchProfile() {
        api.get("auth/me") {(result: Result<User, Error>) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let profile):
                    try? Auth.shared.setUser(profile)
                case .failure(let error):
                    print("Profile fetching went wrong: \(error)")
                }
            }
        }
    }
    
    func resetForm() {
        email = ""
        password = ""
        firstname = ""
        lastname = ""
        validationErrors.removeAll()
    }
    
    // MARK: - Validation functions
    private func validateSignup() -> Bool {
        _ = validateLogin()
        
        if firstname.isEmpty {
            validationErrors.append(.init(key: "firstname", message: "First name is required"))
        }
        
        if lastname.isEmpty {
            validationErrors.append(.init(key: "lastname", message: "Last name is required"))
        }
        
        return validationErrors.count == 0
    }
    
    private func validateLogin() -> Bool {
        validationErrors.removeAll()
        if email.isEmpty {
            validationErrors.append(.init(key: "email", message: "Email is required"))
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
