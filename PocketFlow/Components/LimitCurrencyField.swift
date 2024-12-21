//
//  LimitCurrencyField.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 30/11/2024.
//

import Foundation
import SwiftUI

struct LimitedCurrencyField: View {
    @Binding private var amount: Float
    let label: String
    
    init(_ label: String, amount: Binding<Float>) {
        self.label = label
        self._amount = amount
    }

    let currencyFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.zeroSymbol = ""
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        return fmt
    }()

    var body: some View {
        TextField(label, value: $amount, formatter: currencyFormatter)
            .keyboardType(.decimalPad)
    
    }
}
