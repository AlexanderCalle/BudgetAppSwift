//
//  CircularProgressView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 23/11/2024.
//

import Foundation
import SwiftUI

struct CircularProgressView: View {
    var progress: Double = 0.0
    
    init(progress: Double) {
        self.progress = progress
    }
    
    init(value: Float, max: Float) {
        if(max == 0) {
            self.progress = .init(0.0)
        } else {
            self.progress = .init(value / max)
        }
    }
    
    var body: some View {
        ZStack {
            Text(((100*progress).rounded(.up) / 100), format: .percent)
                .font(.footnote)
                
            Circle()
                .stroke(Color.purple.opacity(0.2), lineWidth: 5)
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    Color.purple,
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}

#Preview {
    CircularProgressView(value: 100, max: 100)
        .frame(width: 35, height: 35)
}
