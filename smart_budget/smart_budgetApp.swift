//
//  smart_budgetApp.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 06/10/2024.
//

import SwiftUI
import MijickPopups

@main
struct smart_budgetApp: App {
    var body: some Scene {
        WindowGroup {
            RootScreen()
                .environmentObject(Auth.shared)
                .fontDesign(.rounded)
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
    }
}
