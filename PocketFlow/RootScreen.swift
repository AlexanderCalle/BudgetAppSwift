//
//  RootScreen.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import SwiftUI
import SwiftData
import MijickPopups



struct RootScreen: View {

    @EnvironmentObject var auth: Auth
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @Query private var settings: [Settings]
    
    var body: some View {
       MainView()
            .onAppear(perform: {
                if settings.isEmpty {
                    context.insert(Settings(darKMode: colorScheme == .dark))
                }
            })
            .environment(settings.first ?? Settings())
    }
}

struct MainView: View {
    var body: some View {
        PrimaryScreen()
            .registerPopups() { $0
                .center {
                    $0.backgroundColor(.background)
                        .cornerRadius(Constants.PopupCornerRadius)
                      .popupHorizontalPadding(Constants.PopupHorizontalPadding)
                      .tapOutsideToDismissPopup(true)
                }
                .vertical {
                    $0.backgroundColor(.background)
                      .cornerRadius(Constants.PopupCornerRadius)
                      .enableStacking(true)
                      .tapOutsideToDismissPopup(true)
                }
            }
    }
}

struct PrimaryScreen: View {
    @EnvironmentObject var auth: Auth
    @Environment(Settings.self) private var settings: Settings

    var body: some View {
        if auth.loggedIn {
            if auth.isNewUser {
                OnboardingScreen()
                    .preferredColorScheme(settings.darKMode ? .dark : .light)
            } else {
                ContentView()
                    .preferredColorScheme(settings.darKMode ? .dark : .light)
            }
        }
        else {
            AuthenticateScreen()
                .preferredColorScheme(settings.darKMode ? .dark : .light)
        }
    }
}

struct Constants {
    static let PopupCornerRadius: CGFloat = 20
    static let PopupHorizontalPadding: CGFloat = 20
}

#Preview {
    RootScreen()
        .fontDesign(.rounded)
        .environmentObject(Auth.shared)
        .environmentObject(AppState())
        .background(Color.background)
        .registerPopups() { $0
            .center {
                $0.backgroundColor(.background)
                    .cornerRadius(Constants.PopupCornerRadius)
                  .popupHorizontalPadding(Constants.PopupHorizontalPadding)
                  .tapOutsideToDismissPopup(true)
            }
            .vertical {
                $0.backgroundColor(.background)
                    .cornerRadius(Constants.PopupCornerRadius)
                  .enableStacking(true)
                  .tapOutsideToDismissPopup(true)
            }
        }
}
