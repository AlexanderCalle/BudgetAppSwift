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
    @Environment(Settings.self) private var settings: Settings
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("👋 Welcom to PocketFlow!")
                .font(.system(size: ContentStyle.FontSize.title, weight: .bold))
                .padding(.vertical, ContentStyle.Padding.large)
            Text("This is a budget app designed to control the flow of your finances.")
                .font(.system(size: ContentStyle.FontSize.subtitle, weight: .regular))
            
            Spacer()
            
            LargeButton("Create an account", theme: .purple, font: .system(size: ContentStyle.FontSize.button, weight: .bold)) {
                Task { await SignupPopup(authenticator: authenticator).present() }
            }
            LargeButton("Login", theme: .secondary, font: .system(size: ContentStyle.FontSize.button, weight: .bold)) {
                Task{ await LoginPopup(authenticator: authenticator).present() }
            }
        }
        .padding()
    }
    
    struct ContentStyle {
        static var cornderRadius: CGFloat = 10
        static var opacity: Double = 0.2
        
        struct Padding {
            static var large: CGFloat = 50
        }
        
        struct FontSize {
            static var title: CGFloat = 30
            static var subtitle: CGFloat = 24
            static var button: CGFloat = 20
        }
    }
}

struct LoginPopup: BottomPopup {
    @ObservedObject var authenticator: AuthenticationViewModel
    @FocusState private var focusedField: Field?
    
    enum Field: Int, Hashable {
        case email
        case password
    }
    
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .heightMode(.large)
    }
    
    var body: some View {
        VStack {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            Spacer()
            ScrollView {
                VStack(spacing: 20) {
                    Text("Login")
                        .font(.title)
                        .fontWeight(.bold)
                        
                    Text("Welcom back!")
                        .font(.title2)
                        .padding(.bottom, 40)
                    
                    if case .failure(let error) = authenticator.loginState {
                        ErrorMessage(error: error)
                    }
                   
                    loginForm
                }
            }
            .onChange(of: authenticator.loginState) { loginState in
                if case .success = loginState {
                    Task { await dismissLastPopup() }
                }
            }
            .padding(.horizontal)
            .cornerRadius(10)
            Spacer()
        }
        .padding()
        .onAppear {
            authenticator.resetForm()
        }
    }
    
    var loginForm: some View {
        VStack {
            TextFieldValidationView(
                label: "Email:",
                validationErrors: $authenticator.validationErrors,
                validationKey: "email"
            ) {
                TextField("Email", text: $authenticator.email)
                    .focused($focusedField, equals: .email)
                    .onSubmit {
                        self.focusNextField($focusedField)
                    }
                    .submitLabel(.next)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
            }
           

            TextFieldValidationView(
                label: "Password:",
                validationErrors: $authenticator.validationErrors,
                validationKey: "password"
            ) {
                SecureField("Password", text: $authenticator.password)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        authenticator.login()
                    }
                    .submitLabel(.go)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
            }
                
            
            LargeButton(
                "Login",
                theme: .primary,
                loading: Binding(
                    get: { authenticator.loginState == .loading },
                    set: { _ in }
                )
            ) {
                authenticator.login()
            }
            .padding(.top, 20)
    
            Button {
                Task { await RequestPasswordResetPopup(authViewModel: authenticator).present() }
            } label: {
                Text("Forgot Password?")
                    .font(.headline)
                    .foregroundColor(Color.primary)
                    .underline()
            }
        }
    }
       
}

struct SignupPopup: BottomPopup {
    @ObservedObject var authenticator: AuthenticationViewModel
    @FocusState var focusedField: Field?
    
    enum Field: Int, Hashable {
        case email
        case password
        case firstname
        case lastname
    }
    
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .heightMode(.large)
    }
    
    var body: some View {
        VStack {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            Spacer()
            ScrollView {
                VStack(spacing: 20) {
                    Text("Signup for PocketFlow")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 40)
                    
                    if case .failure(let error) = authenticator.SignupState {
                        ErrorMessage(error: error)
                    }
                    
                    TextFieldValidationView(
                        label: "Email:",
                        validationErrors: $authenticator.validationErrors,
                        validationKey: "email"
                    ) {
                        TextField("Email", text: $authenticator.email)
                            .focused($focusedField, equals: .email)
                            .onSubmit { self.focusNextField($focusedField) }
                            .submitLabel(.next)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }
                   
                    TextFieldValidationView(
                        label: "Password:",
                        validationErrors: $authenticator.validationErrors,
                        validationKey: "password"
                    ) {
                        SecureField("Password", text: $authenticator.password)
                            .focused($focusedField, equals: .password)
                            .onSubmit { self.focusNextField($focusedField) }
                            .submitLabel(.next)
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                    }
                    
                    TextFieldValidationView(
                        label: "Firstname:",
                        validationErrors: $authenticator.validationErrors,
                        validationKey: "firstname"
                    ) {
                        TextField("Firstname", text: $authenticator.firstname)
                            .focused($focusedField, equals: .firstname)
                            .onSubmit { self.focusNextField($focusedField) }
                            .submitLabel(.next)
                    }
                    
                    TextFieldValidationView(
                        label: "Lastname:",
                        validationErrors: $authenticator.validationErrors,
                        validationKey: "lastname"
                    ) {
                        TextField("Lastname", text: $authenticator.lastname)
                            .focused($focusedField, equals: .lastname)
                            .onSubmit { authenticator.signup() }
                            .submitLabel(.go)
                    }
                    
                    LargeButton(
                        "Signup",
                        theme: .primary,
                        loading: Binding<Bool?>(
                            get: { authenticator.SignupState == .loading },
                            set: { _ = $0 }
                        )
                    ) {
                        authenticator.signup()
                    }
                    .padding(.top, 20)

                }
            }
            .onChange(of: authenticator.SignupState) { SignupState in
                if case .success = SignupState {
                    Task { await dismissLastPopup() }
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .onAppear {
            authenticator.resetForm()
        }
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
