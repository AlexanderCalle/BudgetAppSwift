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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            
            VStack(alignment: .leading) {
                Text("Firstname:")
                TextField("Firstname...", text: Binding(
                    get: { profileViewModel.profile?.firstname ?? "" },
                    set: { profileViewModel.profile!.firstname = $0 }
                ))
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                if(profileViewModel.validationErrors.contains(where: { $0.key == "firstname" })) {
                    Text(profileViewModel.validationErrors.first(where: { $0.key == "firstname" })?.message ?? "")
                        .foregroundColor(.danger)
                }
            }
            VStack(alignment: .leading) {
                Text("Lastname:")
                TextField("Lastname...", text: Binding(
                    get: { profileViewModel.profile?.lastname ?? "" },
                    set: { profileViewModel.profile!.lastname = $0 }
                ))
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                if(profileViewModel.validationErrors.contains(where: { $0.key == "lastname" })) {
                    Text(profileViewModel.validationErrors.first(where: { $0.key == "lastname" })?.message ?? "")
                        .foregroundColor(.danger)
                }
            }
            
            Button {
                profileViewModel.editProfile()
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
