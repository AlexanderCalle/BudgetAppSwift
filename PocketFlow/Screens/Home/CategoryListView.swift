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
        VStack(spacing: 12) {
            HStack {
                Text("Categories")
                    .font(.title)
                Spacer()
            }
           
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
        }
        .padding(.top, 5)
    }
    
    private var categorieSections: some View {
        ForEach(categories.group(by: { $0.type }).sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { key, values in
            Section(header:
                Text(key.rawValue)
            ) {
                categoriesView(values)
            }
        }
    }
    
    private func categoriesView(_ categoriesList: [Categorie]) -> some View {
        ForEach(categoriesList, id: \.id) { category in
            CategoryRow(category: category)
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
