//
//  ChangeCurrencyPopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 12/12/2024.
//

import SwiftUI
import MijickPopups

struct ChangeCurrencyPopup: BottomPopup {
    @Bindable var settings: Settings
    @State var selectedType: Currency
    
    var body: some View {
        VStack {
            CloseButton { Task { await dismissLastPopup() } }
            Spacer()
            Text("Select Currency")
                .font(.headline)
            VStack(spacing: ContentStyle.Spacing) {
                ForEach(Currency.allCases, id: \.self) { type in
                    SelectionRow(
                        title: type.rawValue,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                    }
                }
            }
            .padding()
            
            LargeButton(
                "Save and close",
                theme: .primary
            ) {
                settings.currency = selectedType
                Task { await dismissLastPopup() }
            }
            .padding(.top, ContentStyle.Padding.Top)
        }
        .padding(.vertical, ContentStyle.Padding.Vertical)
        .padding(.leading, ContentStyle.Padding.Leading)
        .padding(.trailing, ContentStyle.Padding.Trailing)
    }
    
    struct ContentStyle {
        static let Spacing: CGFloat = 20
        
        struct Padding {
            static let Top: CGFloat = 20
            static let Vertical: CGFloat = 20
            static let Leading: CGFloat = 24
            static let Trailing: CGFloat = 16
        }
    }
}
