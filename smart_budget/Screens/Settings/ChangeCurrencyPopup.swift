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
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: { Task { await dismissLastPopup() }})
                {
                    Image(systemName: "xmark")
                        .padding(8)
                        .background(.secondary.opacity(0.2))
                        .cornerRadius(.infinity)
                        .tint(.primary)
                }
            }
            Spacer()
            Text("Select Currency")
                .font(.headline)
            VStack(spacing: 16) {
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

            Button(action: {
                settings.currency = selectedType
                Task { await dismissLastPopup() }
            }) {
                Text("Save and close")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .foregroundColor(.background)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding(.vertical, 20)
        .padding(.leading, 24)
        .padding(.trailing, 16)
    }
}
