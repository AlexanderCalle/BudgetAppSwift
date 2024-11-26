//
//  TobBarView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 23/11/2024.
//

import SwiftUI

struct TopBarView: View {
    @Environment(Router.self) var router
    var body: some View {
        HStack {
            Text("Dashboard")
                .font(.title)
            Spacer()
            Button(action: {
                router.navigate(to: .addAmount)
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
            }
            .frame(width: 25, height: 25)
        }
        .tint(.primary)
    }
}

#Preview {
    TopBarView()
}
