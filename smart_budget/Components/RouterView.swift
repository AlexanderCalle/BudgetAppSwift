//
//  RouterView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import Foundation
import SwiftUI

struct RouterView<Content: View>: View {
     var router: Router = Router()
    // Our root view content
    private let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                content
                    .navigationDestination(for: Router.Route.self) { route in
                        router.view(for: route)
                    }
                    .background(Color.background)
                    .frame(width: .infinity, height: .infinity)
            }
        }
        .environment(router)
    }
}
