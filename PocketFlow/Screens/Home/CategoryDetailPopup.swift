//
//  CategoryDetailPopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 03/12/2024.
//

import SwiftUI
import MijickPopups

struct CategoryDetailPopup: BottomPopup {
    @ObservedObject var categoryStore: CategoryStore
    @Environment(Settings.self) var settings: Settings
    
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .heightMode(.large)
    }
    
    var body: some View {
        let category = categoryStore.selectedCategory!
        VStack {
            VStack(spacing: 20) {
                HStack (alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(category.name)
                            .font(.system(size: 20, weight: .bold))
                        Text(category.description ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        Task { await EditCategoryPopup(categoriesStore: categoryStore).present() }
                    } label: {
                        Image(systemName: "pencil")
                            .padding(8)
                            .foregroundColor(.primary)
                            .background(.secondary.opacity(0.2))
                            .cornerRadius(.infinity)
                    }
                    Button {
                        Task { await dismissLastPopup() }
                    } label: {
                        Image(systemName: "xmark")
                            .padding(8)
                            .foregroundColor(.primary)
                            .background(.secondary.opacity(0.2))
                            .cornerRadius(.infinity)
                    }
                }
                .tint(.primary)
                HStack {
                    CircularProgressView(value: category.totalExpenses ?? 0, max: category.max_expense ?? 0)
                        .frame(width: 30)
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack(spacing: 4) {
                            Text(category.max_expense ?? 0, format: .defaultCurrency(code: settings.currency.rawValue))
                            Text(category.type == .savings ? "Target" : "Budget")
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 4) {
                            Text(category.totalExpenses ?? 0, format: .defaultCurrency(code: settings.currency.rawValue))
                            Text(category.type == .savings ? "Funded" : "Spent")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Divider()
            ScrollView {
                VStack(alignment: .leading) {
                    if category.expenses == nil || category.expenses?.count == 0 {
                        Spacer()
                        VStack(spacing: 0) {
                            Text("🏜️")
                                .font(.system(size: 70))
                            
                            Text("No expenses found")
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                                ForEach(category.expenses!.groupedBy(dateComponents: [.day, .month, .year]).sorted(by: { $0.key > $1.key }), id: \.key) {key, value in
                                    Section {
                                        ForEach(value) {expense in
                                            ExpenseRow(expense: expense)
                                        }
                                    } header: {
                                        HStack {
                                            Text(key.formatted(date: .complete, time: .omitted))
                                            Spacer()
                                        }
                                        .foregroundColor(.secondary)
                                        .padding(5)
                                        .background(Color.background)
                                    }
                                }
                            }
                        }
                        .padding(5)
                    }
                }
                
            }
        }
        .padding()
        .tint(.purple)
    }
    
    private func ExpenseRow(expense: Expense) -> some View {
        HStack {
            Circle()
                .foregroundColor(.purple)
                .frame(width: 10)
            Text(expense.name)
            Spacer()
            Text(expense.amount, format: .defaultCurrency(code: settings.currency.rawValue))
                .font(.headline)
                .foregroundColor(.secondary)
                
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
    }
}
