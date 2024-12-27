//
//  CategoryListView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 22/11/2024.
//

import SwiftUI

struct CategoryListView: View {
    @ObservedObject var categoryStore: CategoryStore
    @Environment(Settings.self) var settings: Settings
    
    var categories: [Categorie]
    var onAddCategory: () -> Void
    @State var isExpanded: Set<String> = []
    
    var body: some View {
        VStack(spacing: 20) {
            categorieSections
            
            Button {
                onAddCategory()
            } label: {
                Label("Add Category", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .tint(.gray)
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 1)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundColor(.gray)
                    }
                    .tint(.gray)
            }
            .padding(.bottom, 15)
        }
        .padding(.top, 5)
    }
    
    private var categorieSections: some View {
        VStack(spacing: 40) {
            ForEach(categories.group(by: { $0.type }).sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { key, values in
                VStack(spacing: 12) {
                    categoryTypeOverview(categories: values, type: key)
                    categoriesView(values)
                }
            }
        }
    }
    
    private func categoryTypeOverview(categories: [Categorie], type: CategoryType) -> some View {
        let budgetted = categories.reduce(into: 0) { acc, curr in
                acc += curr.max_expense ?? 0
        }
        let amount = categories.reduce(into: 0) { acc, curr in
            acc += curr.totalExpenses ?? 0
        }
        return VStack {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), alignment: .leading),
                    GridItem(.fixed(80), alignment: .trailing),
                    GridItem(.fixed(90), alignment: .trailing)
                ],
                spacing: 5 // Row spacing
            ) {
                Text(type == .savings ? "Savings" : "Monthly")
                Text(type == .savings ? "Target" : "Budgeted")
                Text(type == .savings ? "Funded" :"Left")
                Text("\(categoryStore.daysLeftInCurrentMonth()) Days left")
                Text(budgetted, format: .defaultCurrency(code: settings.currency.rawValue))
                Text(type == .savings ? amount : (budgetted - amount), format: .defaultCurrency(code: settings.currency.rawValue))
            }
            .padding(10)
            .font(.footnote)
            .foregroundColor(.primary.opacity(0.7))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.1))
                    .stroke(.secondary.opacity(0.2), lineWidth: 2)
            }
        }
        .padding(.horizontal, 1)
    }
    
    private func categoriesView(_ categoriesList: [Categorie]) -> some View {
        VStack(spacing: 12) {
            ForEach(categoriesList, id: \.id) { category in
                CategoryRow(category: category)
            }
        }
    }
    
    private func CategoryRow(category: Categorie) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), alignment: .leading), // Icon and label column
                GridItem(.fixed(80), alignment: .trailing), // Gray text column
                GridItem(.fixed(90), alignment: .trailing)  // Green text column
            ],
            spacing: 16 // Row spacing
        ) {
            Text(category.name)
                .font(.headline)
            Text(category.max_expense ?? 0, format: .defaultCurrency(code: settings.currency.rawValue))
                .font(.system(size: 14))
            Text(((category.max_expense ?? 0 ) - (category.totalExpenses ?? 0)), format: .defaultCurrency(code: settings.currency.rawValue))
                .font(.system(size: 14))
                .padding(5)
                .foregroundColor(category.totalPercentage < 0.7 ? .successForeground : category.totalPercentage < 0.9 ? .warningForeground : .dangerForeground
                )
                .background(category.totalPercentage < 0.7 ? .successBackground : category.totalPercentage < 0.9 ? .warningBackground : .dangerBackground)
                .clipShape(.capsule)
        }
        .padding(10)
        .background(.secondary.opacity(0.1))
        .cornerRadius(10)
        .onTapGesture {
            categoryStore.selectCategory(category: category)
            Task { await CategoryDetailPopup(categoryStore: categoryStore).present() }
        }

    }
    
    
}
//
//#Preview {
//    CategoryListView([
//        Categorie(id: "1", name: "Food", max_expense: 100, expenses: [
//            Expense(id: "1", name: "Mc Donalds", amount: 10.5, date: Date(), type: .cash),
//            Expense(id: "2", name: "Delhaize", amount: 23.34, date: Date(), type: .card)
//        ], totalExpenses: 10.5),
//        Categorie(id: "2", name: "Transport", expenses: []),
//        Categorie(id: "3", name: "Healthcare", expenses: []),
//    ]){
//        
//    }.padding()
//        .environment(Router())
//}
