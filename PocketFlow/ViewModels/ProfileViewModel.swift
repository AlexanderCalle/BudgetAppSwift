//
//  ProfileViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 11/12/2024.
//

import Foundation

class ProfileViewModel: ObservableObject {
    
    @Published var profile: User? = try? Auth.shared.getUser()
    
    // MARK: -- Edit user
    @Published var editState: ViewState<Bool> = .idle
    @Published var validationErrors: [ValidationError] = []
    
    // MARK: -- Change password
    @Published var changePasswordState: ViewState<Bool> = .idle
    @Published var changePasswordValidationErrors: [ValidationError] = []
    @Published var oldPassword: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    let api = ApiService()
    
    func editProfile() {
        guard profile != nil else { return }
        guard validate() else { return }
        
        editState = .loading
        
        api.put("auth/me", body: profile!) { [weak self] (result: Result<User, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.editState = .success(true)
                    let user = (self?.profile)!
                    try? Auth.shared.setUser(user)
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        self?.editState = .failure(networkError)
                    }
                    if let apiError = error as? ApiError {
                        if case .badRequest(let decodedMessage) = apiError {
                            switch(decodedMessage) {
                            case .detailed(let details, _, _):
                                details.forEach { detail in
                                    self?.validationErrors.append(ValidationError(key: detail.property, message: detail.message))
                                }
                                self?.editState = .failure(apiError)
                            default:
                                self?.editState = .failure(apiError)
                            }
                        } else {
                            self?.editState = .failure(apiError)
                        }
                    } else {
                        self?.editState = .failure(error)
                    }
                }
            }
        }
    }
    
    
    func editPassword() {
        guard validatePassword() else { return }
        
        changePasswordState = .loading
        
        let body = ChangePassword(oldPassword: oldPassword, password: password)
        
        api.put("auth/me/change-password", body: body) { [weak self] (result: Result<ChangePassword, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.changePasswordState = .success(true)
                case .failure(let error):
                    print(error.localizedDescription)
                    if let networkError = error as? NetworkError {
                        self?.changePasswordState = .failure(networkError)
                    }
                    if let apiError = error as? ApiError {
                        if case .badRequest(let decodedMessage) = apiError {
                            switch(decodedMessage) {
                            case .detailed(let details, _, _):
                                details.forEach { detail in
                                    self?.validationErrors.append(ValidationError(key: detail.property, message: detail.message))
                                }
                                self?.changePasswordState = .failure(apiError)
                            default:
                                self?.changePasswordState = .failure(apiError)
                            }
                        } else {
                            self?.changePasswordState = .failure(apiError)
                        }
                    } else {
                        self?.changePasswordState = .failure(error)
                    }
                }
            }
        }
    }
    
    private func validatePassword() -> Bool {
        validationErrors.removeAll()
        if oldPassword.isEmpty {
            validationErrors.append(.init(key: "oldPassword", message: "Current password is required"))
        }
        if password.isEmpty {
            validationErrors.append(.init(key: "password", message: "Password is required"))
        }
        
        if confirmPassword != password {
            validationErrors.append(.init(key: "confirmPassword", message: "Passwords do not match"))
        }
        
        return validationErrors.count == 0
    }
    
    private func validate() -> Bool {
        validationErrors.removeAll()
        if let name = profile?.firstname, name.isEmpty {
            validationErrors.append(.init(key: "firstname", message: "Firstname is required"))
        }
        
        if let name = profile?.lastname, name.isEmpty {
            validationErrors.append(.init(key: "lastname", message: "Lastname is required"))
        }
        
        if let email = profile?.email {
            if email.isEmpty {
                validationErrors.append(.init(key: "email", message: "Email is required"))
            }
            if !validateEmail(email) {
                validationErrors.append(.init(key: "email", message: "Invalid email format"))
            }
        }
        
        return validationErrors.count == 0
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}
