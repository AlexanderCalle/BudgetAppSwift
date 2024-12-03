//
//  SettingsView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
            Button {
                Auth.shared.logout()
            } label: {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.danger)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView()
        .background(Color.background)
}
