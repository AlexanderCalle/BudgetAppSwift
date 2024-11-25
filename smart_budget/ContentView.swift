//
//  ContentView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RouterView {
                HomeView()
            }
                .tabItem { Image(systemName: "house") }
                .background(Color.background)

            RouterView {
                ExpensesView()
            }
                .tabItem { Image(systemName: "banknote") }
                .background(Color.background)

            RouterView {
                SettingsView()
            }
                .tabItem { Image(systemName: "gearshape") }
                .background(Color.background)

        }
        .accentColor(.purple)
    }
}


#Preview {
    ContentView()
}
