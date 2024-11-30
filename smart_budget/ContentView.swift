//
//  ContentView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI
import CoreHaptics
import MijickPopups

struct ContentView: View {
    @State var selected = 1

    var body: some View {
        TabView(selection: $selected) {
            RouterView {
                HomeView()
            }
            .tabItem { Image(systemName: "house") }
            .tag(1)
            
            
            RouterView {
                ExpensesView()
            }
            .tabItem { Image(systemName: "creditcard") }
            .tag(2)
            
            RouterView {
                SettingsView()
            }
            .tabItem { Image(systemName: "gearshape") }
            .tag(3)
            
        }
        .sensoryFeedback(.impact(weight: .light), trigger: selected)
        .accentColor(.purple)
        .background(Color.background)
    }
}


#Preview {
    ContentView()
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
