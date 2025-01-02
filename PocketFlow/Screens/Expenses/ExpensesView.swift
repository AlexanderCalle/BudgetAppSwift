//
//  ExpensesView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI

struct ExpensesView: View {
    @Environment(Settings.self) var settings: Settings
    @EnvironmentObject var appState: AppState
    var category: Categorie? = nil
    @StateObject var expensesViewModel = ExpensesViewModel()
    
    
    var body: some View {
        VStack {
            TopBarView("Expenses")
            categoryButtons
            ScrollView {
                StateViewLoader(state: expensesViewModel.expenses) { expenses in
                    if expenses.count == 0 {
                        emptyExpensesView
                    } else {
                        ExpensesList(expenses)
                    }
                }
            }
            .refreshable {
                expensesViewModel.fetchExpenses()
                expensesViewModel.fetchCategories()
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .onAppear { expensesViewModel.SelectCategory(category) }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var categoryButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            StateViewLoader(state: expensesViewModel.categories, showMessages: false) { categories in
                HStack {
                    CategorySelector(nil)
                    Divider()
                    ForEach(categories) { category in
                        CategorySelector(category)
                    }
                }
                .frame(maxHeight: ContentStyle.CategoriesMaxHeight)
            }
        }
        .padding(.vertical, ContentStyle.Padding.Section)
    }
    
    private var  emptyExpensesView: some View {
        VStack {
            Spacer()
            VStack(spacing: ContentStyle.Spacing.None) {
                Text("🏜️")
                    .font(.system(size: ContentStyle.FontSize.EmptyStateImage))
                    
                Text("No expenses found")
            }
            .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private func CategorySelector(_ category: Categorie?) -> some View {
        Text(category?.name ?? "All expenses")
            .foregroundColor(
                expensesViewModel.selectedCategory?.id == category?.id ? .white : .secondary
            )
            .font(.system(size: ContentStyle.FontSize.CategoryButton, weight: .bold))
            .padding(.vertical, ContentStyle.Padding.InnerButton.vertical)
            .padding(.horizontal, ContentStyle.Padding.InnerButton.horizontal)
            .background(
                RoundedRectangle(cornerRadius: ContentStyle.CornerRadius.Regular)
                    .inset(by: ContentStyle.Inset)
                    .stroke(
                        expensesViewModel.selectedCategory?.id == category?.id ? .purple : .secondary, lineWidth: ContentStyle.LineWidth)
                    .fill(
                        expensesViewModel.selectedCategory?.id == category?.id ? .purple : .secondary.opacity(ContentStyle.Opacity.Selection)
                    )
            )
            .fixedSize(horizontal: true , vertical: false)
            .onTapGesture {
                expensesViewModel.SelectCategory(category)
            }
    }
    
    private func ExpensesList(_ expenses: [Expense]) -> some View {
        LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
            ForEach(expenses.groupedBy(dateComponents: [.day, .month, .year]).sorted(by: { $0.key > $1.key }), id: \.key) {key, value in
                Section {
                    ForEach(value) {expense in
                        ExpenseRow(expense: expense)
                            .padding(.horizontal, ContentStyle.Padding.Section)
                        if(value.last != expense) {
                            Divider()
                        }
                    }
                } header: {
                    Text(key.formatted(date: .complete, time: .omitted))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(ContentStyle.Padding.Section)
                        .foregroundColor(.secondary)
                        .background(.secondary.opacity(ContentStyle.Opacity.Header))
                        .background(Color.background)
                        .font(.subheadline)
                        .cornerRadius(ContentStyle.CornerRadius.Small)
                }
            }
        }
    }
    
    func performRefresh() {
        expensesViewModel.fetchExpenses()
    }
    
    private func ExpenseRow(expense: Expense) -> some View {
        Button {
            expensesViewModel.SelectExpense(expense)
            Task { await ExpenseDetailPopup(onRefresh: {
                performRefresh()
            }, expensesStore: expensesViewModel).present() }
        } label: {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), alignment: .leading), // Icon and label column
                    GridItem(.fixed(ContentStyle.AmountSize), alignment: .trailing)  // Green text column
                ],
                spacing: ContentStyle.Spacing.ExpenseRow
            ) {
                VStack(alignment: .leading) {
                    Text(expense.name)
                    Text(expense.category?.name ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
              
                Text(expense.amount, format: .defaultCurrency(code: settings.currency.rawValue))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, ContentStyle.Padding.Section)
        }
        .foregroundColor(.primary)
    }
    
    struct ContentStyle {
        static let AmountSize: CGFloat = 80
        static let Inset: CGFloat = 1
        static let LineWidth: CGFloat = 1
        static let CategoriesMaxHeight: CGFloat = 50
        
        struct Opacity {
            static let Header: Double = 0.1
            static let Selection: Double = 0.2
        }
        
        struct Spacing {
            static let None: CGFloat = 0
            static let ExpenseRow: CGFloat = 16
        }
        
        struct Padding {
            static let Section: CGFloat = 8
            
            struct InnerButton {
                static let vertical: CGFloat = 8
                static let horizontal: CGFloat = 16
            }
        }
        
        struct CornerRadius {
            static let Small: CGFloat = 5
            static let Regular: CGFloat = 10
        }
        
        struct FontSize {
            static let CategoryButton: CGFloat = 14
            static let EmptyStateImage: CGFloat = 70
        }
    }
}

#Preview {
    ExpensesView()
        .background(Color.background)
}
