//
//  7DaysChart.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI
import Charts

struct SevenDaysChartView: View {
    let data: [DayExpense]
    let xScale: ClosedRange<Date>

    init(_ data: [DayExpense]) {
        self.data = data
         //Ensure data is not empty and has valid dates
        if let firstDate = data.first?.date, let lastDate = data.last?.date {
            xScale = firstDate...lastDate
        } else {
            xScale = Date()...(Date() + 86400)
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
                    .clipShape(RoundedRectangle(cornerRadius: ContentStyle.CornerRadius))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        .offset(x: ContentStyle.Offset.X, y: ContentStyle.Offset.Y)
                }
            }
            .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading) { _ in
                    AxisValueLabel(horizontalSpacing: ContentStyle.HorizontalSpacing)
                        .font(.footnote)
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: ContentStyle.LineWidth)).foregroundStyle(.gray)
                }
            }
            .animation(.bouncy, value: data)
            .padding(.vertical, ContentStyle.VerticalPadding)
        }
        .frame(maxHeight: ContentStyle.MaxHeight)
    }
    
    struct ContentStyle {
        static let CornerRadius: CGFloat = 2
        struct Offset {
            static let X: CGFloat = 10
            static let Y: CGFloat = 5
        }
        static let HorizontalSpacing: CGFloat = 8
        static let LineWidth: CGFloat = 0.5
        static let VerticalPadding: CGFloat = 10
        static let MaxHeight: CGFloat = 200
    }
}
