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
    
    @FocusState var focusedField: Field?
    enum Field: Int, Hashable {
        case oldPassword
        case password
        case confirmPassword
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            
            TextFieldValidationView(label: "Current password:", validationErrors: $profileViewModel.validationErrors, validationKey: "oldPassword") {
                SecureField("Current password...", text: $profileViewModel.oldPassword)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .oldPassword)
                    .onSubmit { self.focusNextField($focusedField) }
                    .submitLabel(.next)
            }
            Divider()
            
            TextFieldValidationView(label: "New password:", validationErrors: $profileViewModel.validationErrors, validationKey: "password") {
                SecureField("New password...", text: $profileViewModel.password)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .password)
                    .onSubmit { self.focusNextField($focusedField) }
                    .submitLabel(.next)
            }

            TextFieldValidationView(label: "Confirm password:", validationErrors: $profileViewModel.validationErrors, validationKey: "confirmPassword") {
                SecureField("Confirm password...", text: $profileViewModel.confirmPassword)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.done)
            }
            
            LargeButton(
                "Save",
                theme: .primary,
                loading: Binding<Bool?>(
                    get: { profileViewModel.changePasswordState == .loading },
                    set: { _ = $0 }
                )
            ) { profileViewModel.editPassword() }
                .padding(.top, ContentStyle.PaddingTop)
        }
        .onChange(of: profileViewModel.changePasswordState) { _, state in
            if case .success(_) = state {
                Task { await dismissLastPopup() }
            }
        }
        .padding()
    }
    
    struct ContentStyle {
        static let Spacing: CGFloat = 20
        static let PaddingTop: CGFloat = 20
    }
}
