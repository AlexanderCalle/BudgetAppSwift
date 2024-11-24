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
    
    let data: [LineChartData] = [
        LineChartData(date: Date.from(year: 2024, month: 11, day: 18)!, value: 112),
        LineChartData(date: Date.from(year: 2024, month: 11, day: 19)!, value: 53),
        LineChartData(date: Date.from(year: 2024, month: 11, day: 20)!, value: 86),
        LineChartData(date: Date.from(year: 2024, month: 11, day: 21)!, value: 23),
        LineChartData(date: Date.from(year: 2024, month: 11, day: 22)!, value: 10),
        LineChartData(date: Date.from(year: 2024, month: 11, day: 23)!, value: 73),
        LineChartData(date: Date.from(year: 2024, month: 11, day: 24)!, value: 90)
    ]
    
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

#Preview {
    SevenDaysChartView()
}
