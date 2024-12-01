//
//  LoginScreen.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import SwiftUI
import MijickPopups

struct AuthenticateScreen: View {
    
    @StateObject var authenticator = AuthenticationViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("👋 Welcom to Budgety!")
                .font(.system(size: 30, weight: .bold))
                .padding(.vertical, 50)
            Text("This is a budget app designed to help you keep track of your finances.")
                .font(.system(size: 24, weight: .regular))
            
            Spacer()
            
            Button {
                Task { await SignupPopup(authenticator: authenticator).present() }
            } label: {
                Text("Create an account")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button {
                Task{ await LoginPopup(authenticator: authenticator).present() }
            } label: {
                Text("Login")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct LoginPopup: BottomPopup {
    @ObservedObject var authenticator: AuthenticationViewModel
    
    @State var email: String = ""
    @State var password: String = ""
    
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .heightMode(.large)
    }
    
    var body: some View {
        VStack {
            XMarkButton {
                Task { await dismissLastPopup() }
            }
            Spacer()
            VStack(spacing: 20) {
                Text("Login")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                
                VStack(alignment: .leading) {
                    Text("Email:")
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                    if authenticator.errors(forKey: "email").isEmpty == false {
                        ForEach(authenticator.validationErrors.filter { $0.key == "email" }, id: \.self) { validationError in
                           Text(validationError.message)
                               .foregroundStyle(.red)
                       }
                   }
                }
               
                VStack(alignment: .leading) {
                    Text("Password:")
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                    if authenticator.errors(forKey: "password").isEmpty == false {
                        ForEach(authenticator.validationErrors.filter { $0.key == "password" }, id: \.self) { validationError in
                           Text(validationError.message)
                               .foregroundStyle(.red)
                       }
                   }
                }
                Button{
                    authenticator.login(email: email, password: password)
                } label: {
                    if case .loading = authenticator.loginState {
                        ProgressView()
                    } else {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary)
                            .foregroundColor(.background)
                            .cornerRadius(10)
                    }
                }
            }
            .onChange(of: authenticator.loginState) { loginState in
                if case .success = loginState {
                    Task { await dismissLastPopup() }
                }
            }
            .padding()
            .cornerRadius(10)
            Spacer()
        }
        .padding()
    }
}

struct SignupPopup: BottomPopup {
    @ObservedObject var authenticator: AuthenticationViewModel
    
    @State var email: String = ""
    @State var password: String = ""
    @State var firstname: String = ""
    @State var lastname: String = ""
    
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .heightMode(.large)
    }
    
    var body: some View {
        VStack {
            XMarkButton {
                Task { await dismissLastPopup() }
            }
            Spacer()
            VStack(spacing: 20) {
                Text("Login")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                
                VStack(alignment: .leading) {
                    Text("Email:")
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                    if authenticator.errors(forKey: "email").isEmpty == false {
                        ForEach(authenticator.validationErrors.filter { $0.key == "email" }, id: \.self) { validationError in
                           Text(validationError.message)
                               .foregroundStyle(.red)
                       }
                   }
                }
               
                VStack(alignment: .leading) {
                    Text("Password:")
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                    if authenticator.errors(forKey: "password").isEmpty == false {
                        ForEach(authenticator.validationErrors.filter { $0.key == "password" }, id: \.self) { validationError in
                           Text(validationError.message)
                               .foregroundStyle(.red)
                       }
                   }
                }
                
                VStack(alignment: .leading) {
                    Text("Firstname:")
                    TextField("Firstname", text: $firstname)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                    if authenticator.errors(forKey: "firstname").isEmpty == false {
                        ForEach(authenticator.validationErrors.filter { $0.key == "firstname" }, id: \.self) { validationError in
                           Text(validationError.message)
                               .foregroundStyle(.red)
                       }
                   }
                }
                
                VStack(alignment: .leading) {
                    Text("Lastname:")
                    TextField("Lastname", text: $lastname)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                    if authenticator.errors(forKey: "lastname").isEmpty == false {
                        ForEach(authenticator.validationErrors.filter { $0.key == "lastname" }, id: \.self) { validationError in
                           Text(validationError.message)
                               .foregroundStyle(.red)
                       }
                   }
                }
                
                Button{
                    authenticator.signup(email: email, password: password, firstname: firstname, lastname: lastname)
                } label: {
                    if case .loading = authenticator.SignupState {
                        ProgressView()
                    } else {
                        Text("Create account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary)
                            .foregroundColor(.background)
                            .cornerRadius(10)
                    }
                }
            }
            .onChange(of: authenticator.SignupState) { SignupState in
                if case .success = SignupState {
                    Task { await dismissLastPopup() }
                }
            }
            .padding()
            .cornerRadius(10)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AuthenticateScreen()
        .background(Color.background)
        .registerPopups() { $0
            .center {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .popupHorizontalPadding(20)
                  .tapOutsideToDismissPopup(true)
            }
            .vertical {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .enableStacking(true)
                  .tapOutsideToDismissPopup(true)
            }
        }
        
}
