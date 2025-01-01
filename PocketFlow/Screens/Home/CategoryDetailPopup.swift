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
            VStack(spacing: ContentStyle.Spacing.Large) {
                ActionBar(category)
                DetailBar(category)
            }
            Divider()
            ScrollView {
                VStack(alignment: .leading) {
                    if category.expenses == nil || category.expenses?.count == 0 {
                        emptyExpensesList
                    } else {
                        ExpensesList(category.expenses!)
                    }
                }
                
            }
        }
        .padding()
        .tint(.purple)
    }
    
    private func ActionBar(_ category: Categorie) -> some View {
        HStack (alignment: .top) {
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.system(size: ContentStyle.FontSize.Title, weight: .bold))
                Text(category.description ?? "")
                    .font(.system(size: ContentStyle.FontSize.Description))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button {
                Task { await EditCategoryPopup(categoriesStore: categoryStore).present() }
            } label: {
                Image(systemName: "pencil")
                    .padding(ContentStyle.Padding.Medium)
                    .foregroundColor(.primary)
                    .background(.secondary.opacity(ContentStyle.Opacity))
                    .cornerRadius(.infinity)
            }
            Button {
                Task { await dismissLastPopup() }
            } label: {
                Image(systemName: "xmark")
                    .padding(ContentStyle.Padding.Medium)
                    .foregroundColor(.primary)
                    .background(.secondary.opacity(ContentStyle.Opacity))
                    .cornerRadius(.infinity)
            }
        }
        .tint(.primary)
    }
    
    private func DetailBar(_ category: Categorie) -> some View {
        HStack {
            CircularProgressView(value: category.totalExpenses ?? 0, max: category.max_expense ?? 0)
                .frame(width: ContentStyle.ProgressWidth)
            Spacer()
            VStack(alignment: .trailing) {
                HStack(spacing: ContentStyle.Spacing.Small) {
                    Text(category.max_expense ?? 0, format: .defaultCurrency(code: settings.currency.rawValue))
                    Text(category.type == .savings ? "Target" : "Budget")
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: ContentStyle.Spacing.Small) {
                    Text(category.totalExpenses ?? 0, format: .defaultCurrency(code: settings.currency.rawValue))
                    Text(category.type == .savings ? "Funded" : "Spent")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var emptyExpensesList: some View {
        VStack {
            Spacer()
            VStack {
                Text("🏜️")
                    .font(.system(size: ContentStyle.FontSize.EmptyExpense))
                Text("No expenses found")
            }
            .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private func ExpensesList(_ expenses: [Expense]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                ForEach(expenses.groupedBy(dateComponents: [.day, .month, .year]).sorted(by: { $0.key > $1.key }), id: \.key) {key, value in
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
                        .padding(ContentStyle.Padding.Small)
                        .background(Color.background)
                    }
                }
            }
        }
        .padding(ContentStyle.Padding.Small)
    }
    
    private func ExpenseRow(expense: Expense) -> some View {
        HStack {
            Circle()
                .foregroundColor(.purple)
                .frame(width: ContentStyle.CircleWidth)
            Text(expense.name)
            Spacer()
            Text(expense.amount, format: .defaultCurrency(code: settings.currency.rawValue))
                .font(.headline)
                .foregroundColor(.secondary)
                
        }
        .padding(.vertical, ContentStyle.Padding.ExpenseVertical)
        .padding(.horizontal, ContentStyle.Padding.ExpenseHorizontal)
    }
    
    struct ContentStyle {
        
        static let CircleWidth: CGFloat = 10
        static let ProgressWidth: CGFloat = 30
        
        static let Opacity: Double = 0.2
        
        struct Padding {
            static let ExpenseVertical: CGFloat = 8
            static let ExpenseHorizontal: CGFloat = 10
            
            static let Small: CGFloat = 5
            static let Medium: CGFloat = 8
        }
        
        struct FontSize {
            static let EmptyExpense: CGFloat = 70
            
            static let Title: CGFloat = 20
            static let Description: CGFloat = 16
        }
        
        struct Spacing {
            static let Small: CGFloat = 4
            static let Large: CGFloat = 20
        }
    }
}
