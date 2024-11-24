//
//  ContentView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {

        RouterView {
            TabView {
                HomeView()
                    .tabItem { Image(systemName: "house") }
                    .background(Color.background)

                ExpensesView()
                    .tabItem { Image(systemName: "list.bullet") }
                    .background(Color.background)

                SettingsView()
                    .tabItem { Image(systemName: "gearshape") }
                    .background(Color.background)

            }
            .accentColor(.purple)

        }
    
    }
}

#Preview {
    ContentView()
}
