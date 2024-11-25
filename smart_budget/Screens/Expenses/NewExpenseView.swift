//
//  NewExpenseView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 25/11/2024.
//

import SwiftUI

struct NewExpenseView: View {
    @Environment(Router.self) var router: Router
    @State private var amount: String = "0" // Initial amount value
        
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    // Add dismiss action here
                    router.navigateBack()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .padding()
            }
            
            Spacer()
            
            // Display amount
            Text("€\(amount)")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Custom keypad
            NumPad(columns: columns, handleKeyPress: handleKeyPress, handleDelete: handleDelete)
            
            // Continue button
            Button(action: {
                // Add continue action here
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            .padding()
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.background.ignoresSafeArea())
    }
    
    // Handle button press logic
    private func handleKeyPress(_ key: String) {
        if key == "." {
            if !amount.contains(".") {
                amount += "."
            }
        } else if amount == "0" {
            amount = key // Replace leading 0
        } else {
            amount += key // Append key
        }
    }

    func handleDelete() {
        if !amount.isEmpty {
            amount.removeLast()
            if amount.isEmpty || amount == "." {
                amount = "0" // Reset to 0 for empty or invalid state
            }
        }
    }
}

struct NumPad: View {
    let columns: [GridItem]
    let handleKeyPress: (String) -> Void
    let handleDelete: () -> Void

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9"], id: \.self) { key in
                Button(action: {
                    handleKeyPress(key)
                }) {
                    Text(key)
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 70, height: 70)
                }
            }
            NumPadButton(key: ".", action: handleKeyPress)
            NumPadButton(key: "0", action: handleKeyPress)
            Button(action: handleDelete) {
                Image(systemName: "delete.left")
                    .font(.system(size: 25))
                    .foregroundColor(.primary)
                    .frame(width: 70, height: 70)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NewExpenseView()
        .environment(Router())
}
