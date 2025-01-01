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
    
    var body: some View {
        VStack(spacing: ContentStyle.Spacing.Default) {
            categorieSections
            
            Button {
                onAddCategory()
            } label: {
                Label("Add Category", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ContentStyle.Padding.Vertical)
                    .tint(.gray)
                    .cornerRadius(ContentStyle.CornerRadius)
                    .overlay {
                        RoundedRectangle(cornerRadius: ContentStyle.CornerRadius)
                            .inset(by: ContentStyle.Inset)
                            .strokeBorder(style: StrokeStyle(lineWidth: ContentStyle.LineWidth, dash: ContentStyle.DashPattern))
                            .foregroundColor(.gray)
                    }
                    .tint(.gray)
            }
            .padding(.bottom, ContentStyle.Padding.Bottom)
        }
        .padding(.top, ContentStyle.Padding.Top)
    }
    
    private var categorieSections: some View {
        VStack(spacing: ContentStyle.Spacing.Large) {
            ForEach(categories.group(by: { $0.type }).sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { key, values in
                VStack(spacing: ContentStyle.Spacing.Small) {
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
                    GridItem(.fixed(ContentStyle.CategoryRow.BudgetWidth), alignment: .trailing),
                    GridItem(.fixed(ContentStyle.CategoryRow.AmountWidth), alignment: .trailing)
                ],
                spacing: ContentStyle.Overview.Spacing
            ) {
                Text(type == .savings ? "Savings" : "Monthly")
                Text(type == .savings ? "Target" : "Budgeted")
                Text(type == .savings ? "Funded" :"Left")
                Text("\(categoryStore.daysLeftInCurrentMonth) Days left")
                Text(budgetted, format: .defaultCurrency(code: settings.currency.rawValue))
                Text(type == .savings ? amount : (budgetted - amount), format: .defaultCurrency(code: settings.currency.rawValue))
            }
            .padding(ContentStyle.Overview.InnerPadding)
            .font(.footnote)
            .foregroundColor(.primary.opacity(ContentStyle.Opacity.Dark))
            .overlay {
                RoundedRectangle(cornerRadius: ContentStyle.CornerRadius)
                    .fill(.secondary.opacity(ContentStyle.Opacity.Light))
                    .stroke(.secondary.opacity(ContentStyle.Opacity.Default), lineWidth: ContentStyle.Overview.LineWidth)
            }
        }
        .padding(.horizontal, ContentStyle.Overview.OuterPadding)
    }
    
    private func categoriesView(_ categoriesList: [Categorie]) -> some View {
        VStack(spacing: ContentStyle.Spacing.Small) {
            ForEach(categoriesList, id: \.id) { category in
                CategoryRow(category: category)
            }
        }
    }
    
    private func CategoryRow(category: Categorie) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), alignment: .leading), // Category name column
                GridItem(.fixed(ContentStyle.CategoryRow.BudgetWidth), alignment: .trailing), // Budget/Target text column
                GridItem(.fixed(ContentStyle.CategoryRow.AmountWidth), alignment: .trailing)  // Left/Saved text column
            ],
            spacing: ContentStyle.CategoryRow.Spacing
        ) {
            Text(category.name)
                .font(.headline)
            Text(category.max_expense ?? 0, format: .defaultCurrency(code: settings.currency.rawValue))
                .font(.system(size: ContentStyle.CategoryRow.BudgetFontSize))
            AmountCapsule(((category.max_expense ?? 0 ) - (category.totalExpenses ?? 0)), percentage: category.totalPercentage)
        }
        .padding(ContentStyle.CategoryRow.Padding)
        .background(.secondary.opacity(ContentStyle.Opacity.Light))
        .cornerRadius(ContentStyle.CornerRadius)
        .onTapGesture {
            categoryStore.selectCategory(category: category)
            Task { await CategoryDetailPopup(categoryStore: categoryStore).present() }
        }

    }
    
    struct ContentStyle {
        
        static let CornerRadius: CGFloat = 10
        static let LineWidth: CGFloat = 1
        static let DashPattern: [CGFloat] = [4, 4]
        static let Inset: CGFloat = 1
        
        struct Padding {
            static let Top: CGFloat = 5
            static let Bottom: CGFloat = 15
            static let Vertical: CGFloat = 15
        }
        
        struct Opacity {
            static let Light: Double = 0.1
            static let Default: Double = 0.2
            static let Dark: Double = 0.7
        }
        
        struct CategoryRow {
            static let Padding: CGFloat = 10
            static let BudgetFontSize: CGFloat = 14
            static let Spacing: CGFloat = 16
            
            static let BudgetWidth: CGFloat = 80
            static let AmountWidth: CGFloat = 90
        }
        
        struct Spacing {
            static let Small: CGFloat = 12
            static let Default: CGFloat = 20
            static let Large: CGFloat = 40
        }
        
        struct Overview {
            static let OuterPadding: CGFloat = 1
            static let InnerPadding: CGFloat = 10
            static let Spacing: CGFloat = 5
            static let LineWidth: CGFloat = 2
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
