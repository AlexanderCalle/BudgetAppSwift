//
//  AmountCapsule.swift
//  PocketFlow
//
//  Created by Alexander Callebaut on 01/01/2025.
//

import SwiftUI

struct AmountCapsule: View {
    let amount: Float
    var foregroundColor: Color = .successForeground
    var backgroundColor: Color = .successBackground
    
    @Environment(Settings.self) var settings: Settings

    init(_ amount: Float, percentage: Float = 0.5) {
        self.amount = amount
        self.foregroundColor = percentage < 0.7 ? .successForeground : percentage < 0.9 ? .warningForeground : .dangerForeground
        self.backgroundColor = percentage < 0.7 ? .successBackground : percentage < 0.9 ? .warningBackground : .dangerBackground
    }
    
    var body: some View {
        Text(amount, format: .defaultCurrency(code: settings.currency.rawValue))
            .font(.system(size: ContentStyle.FontSize))
            .padding(ContentStyle.Padding)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(.capsule)
    }
    
    struct ContentStyle {
        static let Padding: CGFloat = 5
        static let FontSize: CGFloat = 14
    }
}

#Preview {
    AmountCapsule(10, percentage: 0.2)
}
