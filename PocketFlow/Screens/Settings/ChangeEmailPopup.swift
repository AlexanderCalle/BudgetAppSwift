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
    
    enum Field: Int, Hashable {
        case email
        case confirmEmail
    }
    @FocusState var focusedField: Field?
    
    private func checkEmailValidity() -> Bool {
        guard confirmEmail == profileViewModel.profile?.email else {
            confirmEmailError = "Emails must match"
            return false
        }
        return true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            
            TextFieldValidationView(label: "Email:", validationErrors: $profileViewModel.validationErrors, validationKey: "email") {
                TextField("Email...", text: Binding(
                    get: { profileViewModel.profile?.email ?? "" },
                    set: { profileViewModel.profile!.email = $0 }
                ))
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit { self.focusNextField($focusedField) }
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
            }
        
            confirmEmailInput
            
            LargeButton(
                "Save",
                theme: .primary,
                loading: Binding<Bool?>(
                    get: { profileViewModel.editState == .loading },
                    set: { _ = $0 }
                )
            ) {
                if checkEmailValidity() {
                    profileViewModel.editProfile()
                }
            }
            .padding(.top, ContentStyle.PaddingTop)
        }
        .onChange(of: profileViewModel.editState) { _, state in
            if case .success(_) = state {
                Task { await dismissLastPopup() }
            }
        }
        .padding()
    }
    
    private var confirmEmailInput: some View {
        VStack(alignment: .leading) {
            Text("Confirm Email:")
            TextField("Confirm email...", text: $confirmEmail)
                .padding()
                .background(Color.secondary.opacity(ContentStyle.Opacity))
                .cornerRadius(ContentStyle.CornerRadius)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .confirmEmail)
                .submitLabel(.done)
            if let confirmEmailError = confirmEmailError {
                Text(confirmEmailError)
                    .foregroundStyle(Color.danger)
            }
        }
    }
    
    private struct ContentStyle {
        static let Spacing: CGFloat = 20
        static let PaddingTop: CGFloat = 20
        
        static let CornerRadius: CGFloat = 10
        static let Opacity: CGFloat = 0.2
    }
}
