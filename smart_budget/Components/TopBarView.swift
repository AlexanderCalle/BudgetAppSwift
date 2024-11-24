//
//  TobBarView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 23/11/2024.
//

import SwiftUI

struct TopBarView: View {
    var body: some View {
        HStack {
            Text("Smart Budget")
                .font(.title)
                .padding()
            Spacer()
            Image(systemName: "plus.circle")
            Image(systemName: "person.crop.circle")
        }
    }
}

#Preview {
    TopBarView()
}
