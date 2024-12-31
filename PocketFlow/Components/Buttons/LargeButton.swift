//
//  FullScreenButton.swift
//  PocketFlow
//
//  Created by Alexander Callebaut on 30/12/2024.
//

import SwiftUI

struct LargeButton: View {
    let label: String
    let theme: ButtomTheme
    let font: Font
    @Binding var loading: Bool?
    let action: () -> Void
    
    init(
        _ label: String,
        theme: ButtomTheme = .secondary,
        font: Font = .system(size: ContentStyle.FontSize, weight: ContentStyle.FontWeight),
        loading: Binding<Bool?> = .constant(nil),
        action: @escaping () -> Void
    ) {
        self._loading = loading
        self.label = label
        self.theme = theme
        self.font = font
        self.action = action
    }
    
    var body: some View {
        Button { action() } label: {
            if loading != nil && loading! {
                ProgressView()
                    .tint(theme.style.tintColor)
            } else {
                Text(label)
                    .font(font)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.style.backgroundColor)
                    .foregroundColor(theme.style.foregroundColor)
                    .cornerRadius(ContentStyle.CornerRadius)
            }
        }
    }
    
    struct ContentStyle {
        static let FontWeight: Font.Weight = .regular
        static let FontSize: CGFloat = 18
        static let CornerRadius: CGFloat = 10
        static let Opacity: Double = 0.2
    }
    
    struct ButtonStyle {
        let backgroundColor: Color
        let foregroundColor: Color
        var tintColor: Color = .primary
    }
    
    enum ButtomTheme {
        case primary
        case secondary
        case purple
        case warning
        case custom(background: Color, foreground: Color, tint: Color = .primary)
        
        var style: ButtonStyle {
            switch self {
            case .primary:
                return ButtonStyle(backgroundColor: .primary, foregroundColor: .background)
            case .secondary:
                return ButtonStyle(backgroundColor: .secondary.opacity(ContentStyle.Opacity), foregroundColor: .primary, tintColor: .white)
            case .purple:
                return ButtonStyle(backgroundColor: .purple, foregroundColor: .white)
            case .warning:
                return ButtonStyle(backgroundColor: .danger, foregroundColor: .white, tintColor: .white)
            case .custom(background: let background, foreground: let foreground, let tint):
                return ButtonStyle(backgroundColor: background, foregroundColor: foreground, tintColor: tint)
            }
        }
    }
}
