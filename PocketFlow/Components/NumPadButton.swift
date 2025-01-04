//
//  NumPadButton.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 25/11/2024.
//

import SwiftUI

struct NumPadButton: View {
    let key: String
    let action: (String) -> Void
    let size: CGFloat
    let font: Font
    
    init(key: String, size: CGFloat = 70, font: Font = .system(size: 22, weight: .bold), action: @escaping (String) -> Void) {
        self.key = key
        self.action = action
        self.size = size
        self.font = font
    }

    var body: some View {
        Button(action: {
            action(key)
        }) {
            Text(key)
                .font(font)
                .foregroundColor(.primary)
                .frame(width: size, height: size)
        }
    }
}

#Preview {
    NumPadButton(key: "0") { key in
        print(key)
    }
}
