//
//  AddAmountView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 25/11/2024.
//

import SwiftUI

struct AddAmountView: View {
    @Environment(Router.self) var router: Router
    @State private var amount: String = "0" // Initial amount value
    @State private var isAnimating: Bool = false
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
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
            amountDisplay
            Spacer()
            // Custom keypad
            NumPad(columns: columns, handleKeyPress: handleKeyPress, handleDelete: handleDelete)
            // Continue button
            Button(action: {
                if let parsedAmount = Float(amount) {
                    print("Parsed amount: \(parsedAmount)")
                    router.navigate(to: .newExpense(amount: parsedAmount))
                } else {
                    print("Invalid amount: \(amount)")
                    // Handle invalid input (optional)
                }
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
        withAnimation(.easeOut(duration: 0.1)) {
            if key == "." {
                if !amount.contains(".") {
                    amount += "."
                }
            } else if amount == "0" {
                amount = key
            } else {
                // Check if there is already a decimal point in the amount
                if let decimalIndex = amount.firstIndex(of: ".") {
                    // Allow up to two digits after the decimal point
                    let decimalPart = amount[amount.index(after: decimalIndex)...]
                    if decimalPart.count < 2 {
                        amount += key
                    }
                } else {
                    // No decimal point yet, allow the number
                    if amount == "0" {
                        amount = key // Replace "0" if it's the first digit
                    } else {
                        amount += key
                    }
                }
            }
            // Trigger animation
            isAnimating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
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
    
    var amountDisplay: some View {
        let lastDigit = amount.last.map(String.init) ?? ""
        let remainingAmount = String(amount.dropLast())
        
        let maxWidth: CGFloat = UIScreen.main.bounds.width - 40 // Adjust for padding
        let textWidth = CGFloat(amount.count) * 50 // Approximate width per character (tweak as needed)
        let scale = min(1.0, maxWidth / textWidth) // Scale down if it exceeds maxWidth


        return HStack(spacing: 0) {
            Text("€\(remainingAmount)")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.primary)
                .contentTransition(.interpolate)

            Text(lastDigit)
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.primary)
                .contentTransition(.interpolate)
                .scaleEffect(isAnimating ? 1.1 : 1.0) // Animate last digit
                .animation(.easeOut(duration: 0.1), value: isAnimating)
        }
        .scaleEffect(scale)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
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
    AddAmountView()
        .environment(Router())
}
