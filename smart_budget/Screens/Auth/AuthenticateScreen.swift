//
//  LoginScreen.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import SwiftUI

struct AuthenticateScreen: View {
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Text("Login")
                    .font(.title)
                    .fontWeight(.bold)
                TextField("Username", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                TextField("Password", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Login") {
                    
                }
            }
            .padding()
            .background(.secondary.opacity(0.2))
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    AuthenticateScreen()
}
