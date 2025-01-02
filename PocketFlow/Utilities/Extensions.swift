//
//  Extensions.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import SwiftUI
import Foundation
import SwiftUICore
import UIKit

// Custom date formatter to support with API
extension DateFormatter {
    static let iso8601WithMilliseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

extension View {
    // Modifier for routes to have the custom back button
    func withCustomBackButton() -> some View {
        modifier(BackButtonModifier())
    }
    // Sets the next focus field
    func focusNextField<F: RawRepresentable>(_ field: FocusState<F?>.Binding) where F.RawValue == Int {
        guard let currentValue = field.wrappedValue else { return }
        let nextValue = currentValue.rawValue + 1
        if let newValue = F.init(rawValue: nextValue) {
            field.wrappedValue = newValue
        }
    }
}

protocol Dated {
    var date: Date { get }
}

// Groups data by a date component (.day, .month, .year)
extension Array where Element: Dated {
    func groupedBy(dateComponents: Set<Calendar.Component>) -> [Date: [Element]] {
        return reduce(into: [Date: [Element]]()) { list, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur.date)
            let date = Calendar.current.date(from: components)!
            
            list[date, default: []].append(cur)
        }
    }
}

// Groups data by a key of choosing
extension Array where Element: Identifiable {
    func group<Key: Hashable>(by keySelector: (Element) -> Key) -> [Key: [Element]] {
        reduce(into: [Key: [Element]]()) { list, current in
            let key = keySelector(current)
            // If key does not exists it creates an empty array
            list[key, default: []].append(current)
        }
    }
}

extension Date {
    // Returns a date for the given parameters
    static func from(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? nil
    }
}

// Narrow formatter (otherwise is dollar -> US$)
extension FormatStyle where Self == FloatingPointFormatStyle<Float>.Currency {
    static func defaultCurrency(code: String) -> FloatingPointFormatStyle<Float>.Currency {
            return .init(code: code)
                .locale(Locale(identifier: "en_US"))
                .presentation(.narrow) // Use "$", "€", etc., without extra text
        }
}
