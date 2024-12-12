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
       PrimaryScreen()
            .onAppear(perform: {
                if settings.isEmpty {
                    context.insert(Settings(darKMode: colorScheme == .dark))
                }
            })
            .environment(settings.first ?? Settings())
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
            } else {
                ContentView()
                    .preferredColorScheme(settings.darKMode ? .dark : .light)
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
        else {
            AuthenticateScreen()
                .preferredColorScheme(settings.darKMode ? .dark : .light)
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

#Preview {
    RootScreen()
        .fontDesign(.rounded)
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
