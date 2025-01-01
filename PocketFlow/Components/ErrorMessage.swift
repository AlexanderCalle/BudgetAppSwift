//
//  ErrorMessage.swift
//  PocketFlow
//
//  Created by Alexander Callebaut on 30/12/2024.
//

import SwiftUI

struct ErrorMessage: View {
    let error: Error
    
    var body: some View {
        if let apiError = error as? ApiError, let message = apiError.getErrorMessage(){
            Message(message)
        }
        if let networkError = error as? NetworkError {
            OfflineMessage(networkError: networkError)
        }
        else {
            Message("Something went wrong, please try again later")
        }
    }
    
    private func Message(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
            Text(message)
            Spacer()
        }
        .padding()
        .background(.dangerBackground)
        .foregroundColor(.dangerForeground)
        .cornerRadius(ContentStyle.CornerRadius)
    }
    
    struct ContentStyle {
        static let VerticalPadding: CGFloat = 8
        static let CornerRadius: CGFloat = 10
    }
}
