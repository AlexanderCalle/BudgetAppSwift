//
//  Expense.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation

struct Expense: Codable, Identifiable {
    var id: String
    var name: String
    var description: String?
    var amount: Float
    var date: Date?
    var type: ExpenseType?
}

enum ExpenseType: String, Codable, CaseIterable {
    case card = "CARD"
    case transfer = "TRANSFER"
    case cash = "CASH"
    case unknown
}
