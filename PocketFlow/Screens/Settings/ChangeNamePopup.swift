//
//  ChangeNamePopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 11/12/2024.
//

import Foundation
import SwiftUI
import MijickPopups

struct ChangeNamePopup: BottomPopup {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @FocusState var focusedField: Field?
    enum Field: Int, Hashable {
        case firstname
        case lastname
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            
            TextFieldValidationView(label: "Firstname:", validationErrors: $profileViewModel.validationErrors, validationKey: "firstname") {
                TextField("Firstname...", text: Binding(
                    get: { profileViewModel.profile?.firstname ?? "" },
                    set: { profileViewModel.profile!.firstname = $0 }
                ))
                .focused($focusedField, equals: .firstname)
                .onSubmit { self.focusNextField($focusedField) }
                .submitLabel(.next)
            }
            
            TextFieldValidationView(label: "Lastname:", validationErrors: $profileViewModel.validationErrors, validationKey: "lastname"){
                TextField("Lastname...", text: Binding(
                    get: { profileViewModel.profile?.lastname ?? "" },
                    set: { profileViewModel.profile!.lastname = $0 }
                ))
                .focused($focusedField, equals: .lastname)
                .submitLabel(.done)
            }
            
            LargeButton(
                "Save",
                theme: .primary,
                loading: Binding<Bool?>(
                    get: { profileViewModel.editState == .loading },
                    set: { _ = $0 }
                )
            ) { profileViewModel.editProfile() }
                .padding(.top, ContentStyle.PaddingTop)
        }
        .onChange(of: profileViewModel.editState) { _, state in
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
