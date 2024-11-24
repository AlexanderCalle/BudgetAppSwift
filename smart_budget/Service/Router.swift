//
//  Router.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import Foundation
import SwiftUI

final class Router: ObservableObject {
    
    public enum Route: Codable, Hashable {
        case home
        case expenses(categoryId: String?)
        case settings
    }
    
    @Published var path = NavigationPath()
    
    @ViewBuilder func view(for route: Route) -> some View {
            switch route {
            case .home:
                HomeView()
                    .background(Color.background)
                    .withCustomBackButton()
            case .expenses(let str):
                ExpensesView()
                    .background(Color.background)
                    .withCustomBackButton()
            case .settings:
                SettingsView()
                    .background(Color.background)
                    .withCustomBackButton()
            }
        }
    
    func navigate(to destination: Route) {
        path.append(destination)
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}
