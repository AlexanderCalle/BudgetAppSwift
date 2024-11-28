//
//  LineChartData.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import Foundation

struct DayExpense: Identifiable, Codable, Equatable {
    var id: UUID = .init()
    
    var date: Date
    var value: Double
    
    private enum CodingKeys: String, CodingKey {
        case date
        case value
    }
}
