//
//  RouterView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import Foundation
import SwiftUI

struct RouterView<Content: View>: View {
   
    // Our root view content
    private let content: Content
    var router = Router()
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        @Bindable var routerB = router
        NavigationStack(path: $routerB.path) {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                content
                    .navigationDestination(for: Router.Route.self) { route in
                        router.view(for: route)
                    }
                    .background(Color.background)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(router)
    }
}
