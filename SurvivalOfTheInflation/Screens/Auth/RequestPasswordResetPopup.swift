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
            
            // MARK: Messages
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
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    if let apiError = error as? ApiError, let message = apiError.getErrorMessage() {
                        Text(message)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.dangerBackground)
                .foregroundStyle(Color.dangerForeground)
                .cornerRadius(10)
            }
            
            Text("Enter your email address and we'll send you a link to reset password")
                .padding()
            VStack(alignment: .leading) {
                Text("Email")
                    .font(.headline)
                TextField("Email", text: $authViewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
                if(authViewModel.validationErrors.contains(where: { $0.key == "email" })) {
                    Text(authViewModel.validationErrors.first(where: { $0.key == "email" })?.message ?? "")
                        .foregroundColor(.danger)
                }
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
    
}
