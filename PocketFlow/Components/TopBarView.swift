//
//  TobBarView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 23/11/2024.
//

import SwiftUI

struct TopBarView: View {
    @EnvironmentObject var appState: AppState
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title)
            Spacer()
            Button(action: {
                appState.showAddExpense = true
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
    TopBarView("Dashboard")
}
