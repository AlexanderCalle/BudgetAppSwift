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
        case expenses(category: Categorie)
        case addAmount
        case newExpense(amount: Float)
    }
    
    var path = NavigationPath()
    
    @ViewBuilder func view(for route: Route) -> some View {
            switch route {
            case .expenses(let category):
                ExpensesView(category: category)
                    .background(Color.background)
                    .withCustomBackButton()
            case .addAmount:
                AddAmountView()
                    .background(Color.background)
            case .newExpense(let amount):
                AddExpenseView(amount: amount)
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
