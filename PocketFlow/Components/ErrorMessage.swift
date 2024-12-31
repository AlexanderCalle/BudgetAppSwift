//
//  ErrorMessage.swift
//  PocketFlow
//
//  Created by Alexander Callebaut on 30/12/2024.
//

import SwiftUI

/// Checks the message type and give the corresponding message in a messase box
/// - Parameters:
///   - error: The desired year
struct ErrorMessage: View {
    let error: Error
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
            if let apiError = error as? ApiError, let message = apiError.getErrorMessage(){
                Text(message)
            }
            if let networkError = error as? NetworkError {
                OfflineMessage(networkError: networkError)
            }
            else {
                Text("Something went wrong, please try again later")
            }
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
