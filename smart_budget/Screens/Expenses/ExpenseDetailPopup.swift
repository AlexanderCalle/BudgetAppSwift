//
//  ExpenseDetailPopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 29/11/2024.
//

import SwiftUI
import MijickPopups

struct ExpenseDetailPopup: BottomPopup {
    let onRefresh: () -> Void
    @StateObject var expensesStore: ExpensesViewModel
    
    @State var isConfirmingDelete = false
    
    func performDeleteAction(_ expense: Expense) {
        expensesStore.deleteExpense(expense)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            HStack {
                Spacer()
                Button(action: {
                    Task { await dismissLastPopup() }
                }) {
                    Image(systemName: "xmark")
                        .padding(8)
                        .background(.secondary.opacity(0.2))
                        .cornerRadius(.infinity)
                }
                .font(.headline)
                .foregroundColor(.primary)
            }
            HStack(alignment: .center){
                Spacer()
                Text(expensesStore.selectedExpense!.amount, format: .currency(code: "EUR"))
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(.danger)
                Spacer()
            }
            HStack(spacing: 50) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Name")
                    Label("Date", systemImage: "calendar")
                    Text("Category")
                    Text("Type")
                }
                .foregroundColor(.primary.opacity(0.8))
                VStack(alignment: .leading, spacing: 20) {
                    Text(expensesStore.selectedExpense!.name)
                    Text(expensesStore.selectedExpense!.date, style: .date)
                    Text(expensesStore.selectedExpense!.category?.name ?? "No category")
                    Text(expensesStore.selectedExpense!.type.rawValue)
                }
            }
            .font(.headline)
            Spacer()
            VStack(spacing: 10) {
                Button {
                    Task { await EditExpensePopup(expenseStore: expensesStore,
                                                  editExpense: expensesStore.selectedExpense!).present() }
                } label: {
                    Text("Edit Expense")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.secondary.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                if isConfirmingDelete {
                    HStack {
                        Button {
                            isConfirmingDelete = false
                        } label: {
                            if case .loading = expensesStore.deleteState {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.secondary.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        Button {
                            expensesStore.deleteExpense(expensesStore.selectedExpense!)
                            Task { await dismissLastPopup() }
                        } label: {
                            if case .loading = expensesStore.deleteState {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Delete")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.danger)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                } else {
                    Button {
                        isConfirmingDelete = true
                    } label: {
                        if case .loading = expensesStore.deleteState {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Delete expense")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.danger)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .font(.system(size: 16, weight: .bold))
        }
        .padding(.vertical, 20)
        .padding(.leading, 24)
        .padding(.trailing, 16)
    }
}

struct EditExpensePopup: BottomPopup {
    @StateObject var expenseStore: ExpensesViewModel
    @State var editExpense: Expense
        
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .heightMode(.large)
            .tapOutsideToDismissPopup(false)
            .enableDragGesture(false)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: { Task { await dismissLastPopup() }}) { Image(systemName: "chevron.left")
                        .padding(8)
                        .background(.secondary.opacity(0.2))
                        .cornerRadius(.infinity)
                        .tint(.primary)
                }
                Spacer()
                Text("Edit Expense")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Button {
                    expenseStore.editExpense(id: editExpense.id, name: editExpense.name, amount: editExpense.amount, date: editExpense.date, type: editExpense.type, category: editExpense.category!)
                } label: {
                    if case .loading = expenseStore.editState {
                        ProgressView()
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Capsule().foregroundColor(.purple))
                    } else {
                        Text("Save")
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Capsule().foregroundColor(.purple))
                    }
                }
            }
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.headline)
                    TextField("Enter expense name", text: $editExpense.name)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                    if(expenseStore.validationErrors.contains(where: { $0.key == "name" })) {
                        Text(expenseStore.validationErrors.first(where: { $0.key == "name" })?.message ?? "")
                            .foregroundColor(.dangerBackground)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Spent")
                        .font(.headline)
                    HStack(spacing: 10) {
                        Text("€")
                        LimitedCurrencyField("Spent on?", amount: $editExpense.amount)
                        if(expenseStore.validationErrors.contains(where: { $0.key == "amount" })) {
                            Text(expenseStore.validationErrors.first(where: { $0.key == "amount" })?.message ?? "")
                                .foregroundColor(.dangerBackground)
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                }
                VStack(alignment: .leading) {
                    DatePicker("Date", selection: $editExpense.date, displayedComponents: .date)
                        .font(.headline)
                }
                VStack(alignment: .leading) {
                    Label("Type", systemImage: "creditcard.fill")
                        .font(.headline)
                    Picker("Type", selection: $editExpense.type) {
                        ForEach(ExpenseType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.headline)
                    ScrollView {
                        VStack(alignment: .leading) {
                            if case .success(let categories) = expenseStore.categories {
                                ForEach(categories) { category in
                                    CategorySelectionRow(category: category, isSelected: editExpense.category?.id == category.id, action: {
                                        editExpense.category = category
                                    })
                                }
                            }
                            if case .loading = expenseStore.categories {
                                ProgressView()
                            }
                        }
                    }
                }
            }
            
        }
        .onChange(of: expenseStore.editState) { state in
            if case .success = state {
                Task { await dismissLastPopup() }
            }
        }
        .padding(.vertical, 20)
        .padding(.leading, 24)
        .padding(.trailing, 16)
        .accentColor(.purple)
    }
}


struct LimitedCurrencyField: View {
    @Binding private var amount: Float
    let label: String
    
    init(_ label: String, amount: Binding<Float>) {
        self.label = label
        self._amount = amount
    }

    let currencyFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        return fmt
    }()

    var body: some View {
        TextField(label, value: $amount, formatter: currencyFormatter)
            .keyboardType(.decimalPad)
    }
}

#Preview {
    ExpenseDetailPopup(onRefresh: {}, expensesStore: ExpensesViewModel())
}
