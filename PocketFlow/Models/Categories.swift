//
//  Categories.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation

struct Categorie: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var description: String?
    var max_expense: Float?
    var totalExpenses: Float?
    var expenses: [Expense]?
    var totalPercentage: Float {
        return (totalExpenses ?? 0) / (max_expense ?? 0)
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(Categorie.self, from: data)
    }
    
    init(id: String, name: String, description: String? = nil, max_expense: Float? = nil, expenses: [Expense]? = nil, totalExpenses: Float? = nil, totalPercentage: Float? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.max_expense = max_expense
        self.expenses = expenses
        self.totalExpenses = totalExpenses
        self.totalExpenses = totalExpenses
    }
    
    static func NewRecommended(name: String, description: String? = nil, max_expense: Float? = nil) -> Categorie {
        return Categorie(id: UUID().uuidString, name: name, description: description, max_expense: max_expense)
    }
}

struct CreateEditCategorie: Codable {
    let name: String
    let description: String?
    let max_expense: Float
}
