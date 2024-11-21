//
//  ContentView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 06/10/2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject var categoriesStore = CategoriesStore()
    
    
    var body: some View {
        VStack(
            alignment: .leading
        ) {
            topBarView
            Group {
                
                VStack {
                    if(categoriesStore.isLoading) {
                        ProgressView()
                    } else {
                        List {
                            ForEach(categoriesStore.categories) { category in
                                Section {
                                    if(category.expenses?.isEmpty ?? true) {
                                        Text("No expenses yet")
                                    }
                                    ForEach(category.expenses ?? []) { expense in
                                        ExpenseRow(expense: expense)
                                    }
                                } header: {
                                    Text(category.name)
                                        .font(.title2)
                                }
                                
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
    
    var topBarView: some View {
        let max_expenses = String(format: "%.f", categoriesStore.mainCategory?.max_expense ?? 0)
        return HStack {
            Text("Smart Budget")
                .font(.title)
                .padding()
            Spacer()
            if !categoriesStore.isLoading {
                Group {
                    Text("\(String(format: "%.f", categoriesStore.total_expenses)) / \(max_expenses) €")
                        .padding(5)
                }
                .background(Color.purple.opacity(0.3))
                .cornerRadius(5)
            }
        }
    }
    
    private func ExpenseRow(expense: Expense) -> some View {
        HStack {
            Text(expense.name)
                .font(.headline)
            Spacer()
            Text("\(expense.amount, specifier: "%.2f") €")
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
