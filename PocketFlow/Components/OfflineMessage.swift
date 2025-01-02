//
//  OfflineMessage.swift
//  PocketFlow
//
//  Created by Alexander Callebaut on 31/12/2024.
//

import SwiftUI

struct OfflineMessage: View {
    let networkError: NetworkError?
    var body: some View {
        if let networkError, let message = networkError.errorMessage {
            OfflineView(message: message)
        } else {
            OfflineView(message: "No internet connection")
        }
    }
    
    private func OfflineView(message: String) -> some View {
        HStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle")
            Text(message)
                .font(.headline)
                .padding()
        }
    }
}

#Preview {
    OfflineMessage(networkError: NetworkError.noInternet)
}
