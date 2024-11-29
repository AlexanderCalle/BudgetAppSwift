//
//  ExpenseDetailPopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 29/11/2024.
//

import SwiftUI
import MijickPopups

struct ExpenseDetailPopup: BottomPopup {
    let expense: Expense
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    Task { await dismissLastPopup() }
                }) {
                    Image(systemName: "xmark")
                }
                .font(.headline)
                .foregroundColor(.primary)
            }
            HStack(alignment: .center){
                Spacer()
                Text(-expense.amount, format: .currency(code: "EUR"))
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(.dangerBackground)
                Spacer()
            }
            .padding(.vertical, 40)
            HStack(spacing: 50) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Name")
                    Label("Date", systemImage: "calendar")
                    Text("Category")
                    Text("Type")
                }
                .foregroundColor(.primary.opacity(0.8))
                VStack(alignment: .leading, spacing: 20) {
                    Text(expense.name)
                    Text(expense.date ?? Date(), style: .date)
                    Text(expense.category?.name ?? "No category")
                    Text(expense.type?.rawValue ?? "No type")
                }
            }
            .font(.headline)
            Spacer()
            VStack(spacing: 10) {
                Button {
                    
                } label: {
                    Text("Edit Expense")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.secondary.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                Button {
                    
                } label: {
                    Text("Delete expense")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.dangerBackground)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .font(.system(size: 16, weight: .bold))
        }
        .padding(.vertical, 20)
        .padding(.leading, 24)
        .padding(.trailing, 16)
    }
}

#Preview {
    ExpenseDetailPopup(expense: Expense(id: "1", name: "Expense One", amount: 10.50, date: Date()))
}
