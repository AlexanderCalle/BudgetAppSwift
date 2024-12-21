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
    
    init(key: String, action: @escaping (String) -> Void) {
        self.key = key
        self.action = action
    }

    var body: some View {
        Button(action: {
            action(key)
        }) {
            Text(key)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 70, height: 70)
        }
    }
}

#Preview {
    NumPadButton(key: "0") { key in
        print(key)
    }
}
