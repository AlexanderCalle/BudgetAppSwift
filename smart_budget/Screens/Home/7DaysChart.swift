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
    let xScale: ClosedRange<Date>

    init(_ data: [DayExpense]) {
        self.data = data
         //Ensure data is not empty and has valid dates
        if let firstDate = data.first?.date, let lastDate = data.last?.date {
            xScale = firstDate...lastDate
        } else {
            // Fallback to a default range if data is empty or invalid
            xScale = Date()...(Date() + 86400) // Today to tomorrow
        }
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Last 7 days:")
                .font(.headline)
            Chart {
                ForEach(data, id: \.id) { item in
                    BarMark(
                        x: .value("Weekday", item.date, unit: .weekday),
                        y: .value("Count", item.value),
                        width: .automatic
                    )
                    .foregroundStyle(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        .offset(x: 10, y: 5)
                }
            }
            .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading) { _ in
                    AxisValueLabel(horizontalSpacing: 8)
                        .font(.footnote)
                    
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray)

                }
            }
            .animation(.bouncy, value: data)

//            .chartXScale(domain: xScale)
            .padding(.vertical, 10)
        }
        .frame(maxHeight: 200)
    }
}
