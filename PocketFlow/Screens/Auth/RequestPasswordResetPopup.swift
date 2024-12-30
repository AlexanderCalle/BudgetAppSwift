//
//  RequestPasswordResetPopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 12/12/2024.
//

import Foundation
import SwiftUI
import MijickPopups

struct RequestPasswordResetPopup: BottomPopup {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            XMarkButton { Task { await dismissLastPopup() } }
            Text("Reset Password")
                .font(.title)
                .padding()
            
            // MARK: Messages - Success & Error
            messages
            
            Text("Enter your email address and we'll send you a link to reset password")
                .padding()
            
            TextFieldValidationView(
                label: "Email", 
                validationErrors: $authViewModel.validationErrors,
                validationKey: "email"
            ) {
                TextField("Email", text: $authViewModel.resetEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
            
            Button {
                authViewModel.resetPassword()
            } label: {
                Text("Request Password Reset")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.background)
                    .padding()
                    .background(Color.primary)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    var messages: some View {
        VStack {
            if case .success = authViewModel.resetState {
                HStack {
                    Text("Password reset request sent successfully!")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(Color.successBackground)
                .foregroundStyle(Color.successForeground)
                .cornerRadius(10)
            }
            
            if case .failure(let error) = authViewModel.resetState {
                ErrorMessage(error: error)
            }
        }
    }
    
    struct ContentStyle {
        static let CornerRadius: CGFloat = 10
        static let Spacing: CGFloat = 20
        struct Opacity {
            static let Background: Double = 0.1
        }
    }
}
