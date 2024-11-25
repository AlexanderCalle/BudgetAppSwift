//
//  Router.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import Foundation
import SwiftUI

@Observable
final class Router {
    
    public enum Route: Codable, Hashable {
        case home
        case expenses(category: Categorie)
        case settings
        case newExpense
    }
    
    var path = NavigationPath()
    
    @ViewBuilder func view(for route: Route) -> some View {
            switch route {
            case .home:
                HomeView()
                    .background(Color.background)
                    .withCustomBackButton()
            case .expenses(let category):
                ExpensesView(category: category)
                    .background(Color.background)
                    .withCustomBackButton()
            case .settings:
                SettingsView()
                    .background(Color.background)
                    .withCustomBackButton()
            case .newExpense:
                NewExpenseView()
                    .background(Color.background)
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
