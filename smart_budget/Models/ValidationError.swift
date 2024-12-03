//
//  ValidationError.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 28/11/2024.
//

import Foundation

struct ValidationError: Identifiable, Hashable {
    let id = UUID()  // Conform to `Identifiable`

    let key: String
    let message: String
}
