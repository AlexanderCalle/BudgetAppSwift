//
//  XMarkButton.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 01/12/2024.
//

import SwiftUI

struct XMarkButton: View {
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                action()
            }) {
                Image(systemName: "xmark")
                    .padding(8)
                    .background(.secondary.opacity(0.2))
                    .cornerRadius(.infinity)
            }
            .font(.headline)
            .foregroundColor(.primary)
        }
    }
}

#Preview {
    XMarkButton {
        
    }
}
