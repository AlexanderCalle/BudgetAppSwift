//
//  AddAmountView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 25/11/2024.
//

import SwiftUI

struct AddAmountView: View {
    @EnvironmentObject var appState: AppState
    @Environment(Router.self) var router: Router
    @Environment(Settings.self) var settings: Settings
    
    @State private var amount: String = "0" // Initial amount value
    @State private var isAnimating: Bool = false
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: ContentStyle.Spacing.Large) {
            CloseButton {
                appState.showAddExpense = false
            }
            .padding(.horizontal, ContentStyle.Padding.Default)
           
            Spacer()
            // Display amount
            amountDisplay
            Spacer()
            // Custom keypad
            NumPad(columns: columns, handleKeyPress: handleKeyPress, handleDelete: handleDelete)
            // Continue button
            LargeButton(
                "Continue",
                theme: .purple
            ) {
                if let parsedAmount = Float(amount) {
                    print("Parsed amount: \(parsedAmount)")
                    router.navigate(to: .newExpense(amount: parsedAmount))
                } else {
                    print("Invalid amount: \(amount)")
                    // TODO: Refactor - handle invalid input
                }
            }
            .padding()
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.background.ignoresSafeArea())
    }
    
    // Handle button press logic
    private func handleKeyPress(_ key: String) {
        withAnimation(.easeOut(duration: ContentStyle.Duration.Typing)) {
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

        DispatchQueue.main.asyncAfter(deadline: .now() + ContentStyle.Duration.Animation) {
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
        
        let maxWidth: CGFloat = UIScreen.main.bounds.width - ContentStyle.Padding.NumPad // Adjust for padding
        let textWidth = CGFloat(amount.count) * ContentStyle.FontSize.Amount
        let scale = min(1.0, maxWidth / textWidth) // Scale down if it exceeds maxWidth

        return HStack(spacing: ContentStyle.Spacing.None) {
            Text("\(settings.currency.getSymbol())\(remainingAmount)")
                .font(.system(size: ContentStyle.FontSize.Amount, weight: .bold))
                .foregroundColor(.primary)
                .contentTransition(.interpolate)

            Text(lastDigit)
                .font(.system(size: ContentStyle.FontSize.Amount, weight: .bold))
                .foregroundColor(.primary)
                .contentTransition(.interpolate)
                .scaleEffect(isAnimating ? ContentStyle.Scale.Up : ContentStyle.Scale.None) // Animate last digit
                .animation(.easeOut(duration: ContentStyle.Duration.Typing), value: isAnimating)
        }
        .scaleEffect(scale)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, ContentStyle.Padding.DisplayAmount)
    }
    
    struct ContentStyle {
        static let GridContent: GridItem = GridItem(.flexible())
        
        struct Spacing {
            static let None: CGFloat = 0
            static let Medium: CGFloat = 10
            static let Large: CGFloat = 20
        }
        
        struct FontSize {
            static let Amount: CGFloat = 50
        }
        
        struct Padding {
            static let NumPad: CGFloat = 40
            static let DisplayAmount: CGFloat = 16
            static let Default: CGFloat = 10
        }
        
        struct Width {
            static let NumberButton: CGFloat = 50
        }
        
        struct Scale {
            static let Up: CGFloat = 1.1
            static let None: CGFloat = 1
        }
        
        struct Duration {
            static let Animation: TimeInterval = 0.3
            static let Typing: TimeInterval = 0.1
        }
    }
}

struct NumPad: View {
    let columns: [GridItem]
    let handleKeyPress: (String) -> Void
    let handleDelete: () -> Void

    var body: some View {
        LazyVGrid(columns: columns, spacing: ContentStyle.Spacing) {
            ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9"], id: \.self) { key in
                Button(action: {
                    handleKeyPress(key)
                }) {
                    NumPadButton(key: key, action: handleKeyPress)
                }
            }
            NumPadButton(key: ".", action: handleKeyPress)
            NumPadButton(key: "0", action: handleKeyPress)
            Button(action: handleDelete) {
                Image(systemName: "delete.left")
                    .font(.system(size: ContentStyle.FontSize))
                    .foregroundColor(.primary)
                    .frame(width: ContentStyle.Size, height: ContentStyle.Size)
            }
        }
        .padding(.horizontal)
    }
    
    struct ContentStyle {
        static let Spacing: CGFloat = 10
        static let FontSize: CGFloat = 25
        static let Size: CGFloat = 70
    }
}

#Preview {
    AddAmountView()
        .environment(Router())
}
