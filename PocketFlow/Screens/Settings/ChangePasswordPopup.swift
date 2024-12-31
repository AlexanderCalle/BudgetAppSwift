//
//  ChangePasswordPopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 11/12/2024.
//

import Foundation
import SwiftUI
import MijickPopups

struct ChangePasswordPopup: BottomPopup {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            
            VStack(alignment: .leading) {
                Text("Current password:")
                SecureField("Current password...", text: $profileViewModel.oldPassword)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                if(profileViewModel.validationErrors.contains(where: { $0.key == "oldPassword" })) {
                    Text(profileViewModel.validationErrors.first(where: { $0.key == "oldPassword" })?.message ?? "")
                        .foregroundColor(.danger)
                }
            }
            Divider()
            VStack(alignment: .leading) {
                Text("New password:")
                SecureField("New password...", text: $profileViewModel.password)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                if(profileViewModel.validationErrors.contains(where: { $0.key == "password" })) {
                    Text(profileViewModel.validationErrors.first(where: { $0.key == "password" })?.message ?? "")
                        .foregroundColor(.danger)
                }
            }
            VStack(alignment: .leading) {
                Text("Confirm password:")
                SecureField("Confirm password...", text: $profileViewModel.confirmPassword)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                if(profileViewModel.validationErrors.contains(where: { $0.key == "confirmPassword" })) {
                    Text(profileViewModel.validationErrors.first(where: { $0.key == "confirmPassword" })?.message ?? "")
                        .foregroundColor(.danger)
                }
            }
            
            Button {
                profileViewModel.editPassword()
            } label: {
                if case .loading = profileViewModel.changePasswordState {
                    ProgressView()
                        .foregroundStyle(Color.background)
                        .padding()
                } else {
                    Text("Save")
                        .foregroundStyle(Color.background)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.primary)
            .cornerRadius(10)
            .padding(.top, 20)
        }
        .onChange(of: profileViewModel.changePasswordState) { state in
            if case .success(_) = state {
                Task { await dismissLastPopup() }
            }
        }
        .padding()
    }
}
