//
//  7DaysChart.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI
import Charts

struct SevenDaysChartView: View {
    
    // TODO: Switch between week and month overview
    
   let data: [DayExpense]

    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Last 7 days:")
                .font(.headline)
            Chart {
                ForEach(data, id: \.id) { item in
                    BarMark(
                        x: .value("Weekday", item.date, unit: .weekday),
                        y: .value("Count", item.value),
                        width: .fixed(15)
                    )
                    .foregroundStyle(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                }
            }
        }
        .frame(maxHeight: 200)
    }
}
