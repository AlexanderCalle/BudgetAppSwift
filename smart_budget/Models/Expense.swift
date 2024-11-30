//
//  Expense.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation

struct Expense: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var amount: Float
    var date: Date
    var type: ExpenseType
    
    var category: Categorie?
}

enum ExpenseType: String, Codable, CaseIterable {
    case card = "CARD"
    case transfer = "TRANSFER"
    case cash = "CASH"
}

struct CreateExpense: Codable {
    var name: String
    var amount: Float
    var date: Date
    var type: ExpenseType
    
    var categoryId: String
}

