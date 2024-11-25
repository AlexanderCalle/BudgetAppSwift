//
//  ExpensesView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI

struct ExpensesView: View {
    @Environment(Router.self) var router: Router
    var category: Categorie? = nil
    @StateObject var expensesViewModel = ExpensesViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Expenses")
                    .font(.title)
                Spacer()
                Button(action: {
                    router.navigate(to: .newExpense)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                }
                .frame(width: 25, height: 25)
            }
            .tint(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                if case .success(let categories) = expensesViewModel.categories {
                    HStack {
                        Text("All expenses")
                            .foregroundColor(
                                expensesViewModel.selectedCategory == nil ? .white : .purple
                            )
                            .font(.headline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 1)
                                    .stroke(.purple, lineWidth: 1)
                                    .fill(expensesViewModel.selectedCategory == nil ? .purple : .purple.opacity(0.2))
                            )
                            .fixedSize(horizontal: true , vertical: false)
                            .onTapGesture {
                                expensesViewModel.SelectCategory(nil)
                            }
                        
                        Divider()
                        
                        ForEach(categories) { category in
                            Text(category.name)
                                .foregroundColor(
                                    expensesViewModel.selectedCategory?.id == category.id ? .white : .purple
                                )
                                .font(.headline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 1)
                                        .stroke(.purple, lineWidth: 1)
                                        .fill(
                                            expensesViewModel.selectedCategory?.id == category.id ? .purple : .purple.opacity(0.2)
                                        )
                                )
                                .fixedSize(horizontal: true , vertical: false)
                                .onTapGesture {
                                    expensesViewModel.SelectCategory(category)
                                }
                        }
                    }
                    .frame(maxHeight: 50)
                }
            }
            .padding(.vertical, 8)
            ScrollView {
                switch expensesViewModel.expenses {
                case .success(let expenses):
                   ForEach(expenses) { expense in
                        ExpenseRow(expense: expense)
                       Divider()
                    }
                case .loading:
                    ProgressView()
                case .failure(let error):
                    if let error = error as? NetworkError {
                        OfflineView(networkError: error)
                    } else {
                        Text(error.localizedDescription)
                    }
                case .idle:
                    Text("Idle")
                }
                
            }
        }
        .padding()
        .onAppear {
            expensesViewModel.SelectCategory(category)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func OfflineView(networkError: NetworkError?) -> some View {
        if let networkError {
            switch networkError {
            case .invalidURL:
                OfflineView(message: "Api url is invalid")
            case .noInternet:
                OfflineView(message: "No internet connection")
            case .timeout:
                OfflineView(message: "Timeout")
            case .unReachable:
                OfflineView(message: "Server unreachable")
            case .interalError:
                OfflineView(message: "Internal error")
            @unknown default:
                OfflineView(message: "Unknown error")
            }
        } else {
            OfflineView(message: "No internet connection")
        }
    }
    
    private func OfflineView(message: String) -> some View {
        HStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle")
            Text(message)
                .font(.headline)
                .padding()
        }
    }
    
    private func ExpenseRow(expense: Expense) -> some View {
        HStack {
            Text(expense.name)
            Spacer()
            Group {
                Text(expense.type?.rawValue ?? "")
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            .background(Color.accentColor.opacity(0.2))
            .cornerRadius(8)
            Spacer()
            Text("\(expense.amount, specifier: "%.2f") €")
                .font(.headline)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
    }
}

#Preview {

    ExpensesView()
        .environment(Router())
        .background(Color.background)
}
