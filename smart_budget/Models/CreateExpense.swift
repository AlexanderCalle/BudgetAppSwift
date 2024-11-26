//
//  CreateExpense.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 26/11/2024.
//

import Foundation

struct CreateExpense: Codable {
    var name: String
    var description: String?
    var amount: Float
    var date: Date
    var type: ExpenseType
    
    var categoryId: String
}
