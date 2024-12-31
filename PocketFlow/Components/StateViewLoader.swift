//
//  StateViewLoader.swift
//  PocketFlow
//
//  Created by Alexander Callebaut on 31/12/2024.
//

import SwiftUI

struct StateViewLoader<Content: View, T>: View {
    let state: ViewState<T>
    let content: (T) -> Content
    var showMessages: Bool = true
    
    init (state: ViewState<T>, @ViewBuilder content: @escaping (T) -> Content) {
        self.state = state
        self.content = content
    }
    
    init (state: ViewState<T>, showMessages: Bool, @ViewBuilder content: @escaping (T) -> Content) {
        self.state = state
        self.showMessages = showMessages
        self.content = content
    }
    
    var body:  some View {
        switch state {
            case .loading:
                ProgressView()
            case .success(let value):
                content(value)
            case .failure(let error):
                if showMessages {
                    ErrorMessage(error: error)
                } else { EmptyView() }
            case .idle:
                EmptyView()
        }
    }
}

#Preview {
    @Previewable var aState: ViewState<Int> = .success(8)
    StateViewLoader(state: aState) { value in
        VStack {
            Text(value.formatted())
        }
    }
}
