//
//  Settings.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 12/12/2024.
//

import Foundation
import SwiftData

@Model
class Settings {
    var currency: Currency
    var darKMode: Bool
    
    init(currency: Currency = .EUR, darKMode: Bool = false) {
        self.currency = currency
        self.darKMode = darKMode
    }
}

enum Currency: String, Codable, CaseIterable {
    case USD = "USD"
    case EUR = "EUR"
        
    func getSymbol() -> String {
        switch self {
            case .USD: return "$"
            case .EUR: return "€"
        }
    }
}
