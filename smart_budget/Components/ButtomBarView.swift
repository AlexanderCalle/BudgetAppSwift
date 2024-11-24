//
//  ButtomBarView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI

struct ButtomBarView: View {
    @State var activeMenuItem: MenuItem = .home
    var body: some View {
        Divider()
            .padding(0)
        HStack {
            Spacer()
            Button {
                activeMenuItem = .home
            } label: {
                Image(systemName: "house")
                    .imageScale(.large)
                    .tint(activeMenuItem == .home ? .purple : .primary)
            }
            Spacer()
            Button {
                activeMenuItem = .currency
            } label: {
                Image(systemName: "coloncurrencysign.circle")
                    .imageScale(.large)
                    .tint(activeMenuItem == .currency ? .purple : .primary)

            }
            Spacer()
            Button {
                activeMenuItem = .settings
            } label: {
                Image(systemName: "gear")
                    .imageScale(.large)
                    .tint(activeMenuItem == .settings ? .purple : .primary)

            }
            Spacer()
        }
        .padding(.top)
        .tint(.primary)
    }
}

enum MenuItem: CaseIterable {
    case home
    case currency
    case settings
}

#Preview {
    ButtomBarView()
}
