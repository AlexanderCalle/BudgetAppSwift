//
//  ChangeEmailPopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 11/12/2024.
//

import Foundation
import SwiftUI
import MijickPopups

struct ChangeEmailPopup: BottomPopup {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State var confirmEmail: String = ""
    @State var confirmEmailError: String?
    
    private func checkEmailValidity() -> Bool {
        guard confirmEmail == profileViewModel.profile?.email else {
            confirmEmailError = "Emails must match"
            return false
        }
        return true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            
            VStack(alignment: .leading) {
                Text("Email:")
                TextField("Email...", text: Binding(
                    get: { profileViewModel.profile?.email ?? "" },
                    set: { profileViewModel.profile!.email = $0 }
                ))
                .padding()
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(10)
                if(profileViewModel.validationErrors.contains(where: { $0.key == "email" })) {
                    Text(profileViewModel.validationErrors.first(where: { $0.key == "email" })?.message ?? "")
                        .foregroundColor(.danger)
                }
            }
            VStack(alignment: .leading) {
                Text("Confirm Email:")
                TextField("Confirm email...", text: $confirmEmail)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                if confirmEmailError != nil {
                    Text(confirmEmailError!)
                        .foregroundStyle(Color.danger)
                }
            }
            
            Button {
                if checkEmailValidity() {
                    profileViewModel.editProfile()
                }
            } label: {
                if case .loading = profileViewModel.editState {
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
        .onChange(of: profileViewModel.editState) { state in
            if case .success(_) = state {
                Task { await dismissLastPopup() }
            }
        }
        .padding()
    }
}
