//
//  Categories.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation

struct Categorie: Codable, Identifiable {
    var id: String
    var name: String
    var description: String?
    var max_expense: Float?
    var color: String?
    var totalExpenses: Float?
    var expenses: [Expense]?
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(Categorie.self, from: data)
    }
    
    init(id: String, name: String, description: String? = nil, max_expense: Float? = nil, color: String? = nil, expenses: [Expense]? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.max_expense = max_expense
        self.color = color
        self.expenses = expenses
    }
}
