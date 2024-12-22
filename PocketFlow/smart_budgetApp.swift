//
//  smart_budgetApp.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 06/10/2024.
//

import SwiftUI
import MijickPopups
import SwiftData

@main
struct smart_budgetApp: App {
    @StateObject private var appState = AppState()

    
    var body: some Scene {
        WindowGroup {
            RootScreen()
                .environmentObject(Auth.shared)
                .environmentObject(appState)
                .fontDesign(.rounded)
                .background(Color.background)
        }
        .modelContainer(for: Settings.self)
    }
}
