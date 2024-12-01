//
//  RootScreen.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import SwiftUI

struct RootScreen: View {
    
    @EnvironmentObject var auth: Auth
    
    var body: some View {
        if auth.loggedIn {
            ContentView()
        } else {
            AuthenticateScreen()
        }
    }
}

#Preview {
    RootScreen()
        .environmentObject(Auth.shared)
        .background(Color.background)
        .registerPopups() { $0
            .center {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .popupHorizontalPadding(20)
                  .tapOutsideToDismissPopup(true)
            }
            .vertical {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .enableStacking(true)
                  .tapOutsideToDismissPopup(true)
            }
        }
}
