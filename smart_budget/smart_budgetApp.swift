//
//  smart_budgetApp.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 06/10/2024.
//

import SwiftUI

@main
struct smart_budgetApp: App {
    @ObservedObject var router = Router()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
