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
    @Environment(Settings.self) var settings: Settings
    
    @State var isConfirmingDelete = false
    
    func performDeleteAction(_ expense: Expense) {
        expensesStore.deleteExpense(expense)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing.Large) {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            amountDetail
            expenseDetails
            Spacer()
            detailActions
        }
        .padding(.vertical, ContentStyle.Padding.Vertical)
        .padding(.leading, ContentStyle.Padding.Leading)
        .padding(.trailing, ContentStyle.Padding.Trailing)
    }
    
    private var amountDetail: some View {
        HStack(alignment: .center){
            Spacer()
            Text(-expensesStore.selectedExpense!.amount, format: .defaultCurrency(code: settings.currency.rawValue))
                .font(.system(size: ContentStyle.FontSize.Large, weight: .medium))
                .foregroundStyle(.danger)
            Spacer()
        }
    }
    
    private var expenseDetails: some View {
        HStack(spacing: ContentStyle.Spacing.ExtraLarge) {
            VStack(alignment: .leading, spacing: ContentStyle.Spacing.Regular) {
                Text("Name")
                Label("Date", systemImage: "calendar")
                Text("Category")
                Text("Type")
            }
            .foregroundColor(.primary.opacity(0.8))
            VStack(alignment: .leading, spacing: ContentStyle.Spacing.Regular) {
                Text(expensesStore.selectedExpense!.name)
                Text(expensesStore.selectedExpense!.date, style: .date)
                Text(expensesStore.selectedExpense!.category?.name ?? "No category")
                Text(expensesStore.selectedExpense!.type.rawValue)
            }
        }
        .font(.headline)
    }
    
    private var detailActions: some View {
        VStack(spacing: ContentStyle.Spacing.Small) {
            LargeButton(
                "Edit Expense",
                theme: .secondary
            ) {
                Task { await EditExpensePopup(
                    expenseStore: expensesStore,
                    editExpense: expensesStore.selectedExpense!).present() }
            }
            if isConfirmingDelete {
                HStack {
                    LargeButton(
                        "Cancel",
                        theme: .secondary,
                        loading: Binding<Bool?>(
                            get: { expensesStore.deleteState == .loading },
                            set: { _ = $0 }
                        )
                    ) {
                        isConfirmingDelete = false
                    }
                    
                    LargeButton(
                        "Delete",
                        theme: .warning,
                        loading: Binding<Bool?>(
                            get: { expensesStore.deleteState == .loading },
                            set: { _ = $0 }
                        )
                    ) {
                        expensesStore.deleteExpense(expensesStore.selectedExpense!)
                        Task { await dismissLastPopup() }
                    }
                }
            } else {
                LargeButton(
                    "Delete expense",
                    theme: .warning,
                    loading: Binding<Bool?>(
                        get: { expensesStore.deleteState == .loading },
                        set: { _ = $0 })
                ) { isConfirmingDelete = true }
            }
        }
        .onChange(of: expensesStore.deleteState) { _, value in
            if case .success(_) = value {
                NotificationCenter.default.post(name: .expenseCreated, object: nil)
            }
        }
        .font(.system(size: ContentStyle.FontSize.Regular, weight: .bold))
    }
    
    struct ContentStyle {
        static let Opacity: Float = 0.8
        
        struct FontSize {
            static let Regular: CGFloat = 16
            static let Large: CGFloat = 50
        }
        
        struct Spacing {
            static let Small: CGFloat = 10
            static let Regular: CGFloat = 20
            static let Large: CGFloat = 40
            static let ExtraLarge: CGFloat = 50
        }
        
        struct Padding {
            static let Vertical: CGFloat = 20
            static let Leading: CGFloat = 24
            static let Trailing: CGFloat = 16
        }
    }
}

struct EditExpensePopup: BottomPopup {
    @StateObject var expenseStore: ExpensesViewModel
    @Environment(Settings.self) var settings: Settings
    @State var editExpense: Expense
    
    @FocusState var focusedField: Field?
    enum Field: Int, Hashable {
        case name
        case amount
        case date
    }
        
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .heightMode(.large)
            .tapOutsideToDismissPopup(false)
            .enableDragGesture(false)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            HStack {
                backButton
                Spacer()
                Text("Edit Expense")
                    .font(.system(size: ContentStyle.FontSize, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                saveButton
            }
            expenseForm
            categorySelection
        }
        .onChange(of: expenseStore.editState) { _, state in
            if case .success = state {
                NotificationCenter.default.post(name: .expenseCreated, object: nil)
                Task { await dismissLastPopup() }
            }
        }
        .padding(.vertical, ContentStyle.Padding.PopupVertical)
        .padding(.leading, ContentStyle.Padding.PopupLeading)
        .padding(.trailing, ContentStyle.Padding.PopupTrailing)
        .accentColor(.purple)
    }
    
    private var backButton: some View {
        Button(action: { Task { await dismissLastPopup() }}) { Image(systemName: "chevron.left")
                .padding(ContentStyle.Padding.InnerBackButton)
                .background(.secondary.opacity(ContentStyle.Opacity))
                .tint(.primary)
                .clipShape(.circle)
        }
    }
    
    private var saveButton: some View {
        Button {
            expenseStore.editExpense(id: editExpense.id, name: editExpense.name, amount: editExpense.amount, date: editExpense.date, type: editExpense.type, category: editExpense.category!)
        } label: {
            Group {
                if case .loading = expenseStore.editState {
                    ProgressView()
                } else {
                    Text("Save")
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal)
            .padding(.vertical, ContentStyle.Padding.InnerSaveButton)
            .background(Capsule().foregroundColor(.purple))
        }
    }
    
    private var expenseForm: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            TextFieldValidationView(label: "Name", validationErrors: $expenseStore.validationErrors, validationKey: "name") {
                TextField("Enter expense name", text: $editExpense.name)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focusNextField($focusedField)
                    }
            }
            TextFieldValidationView(label: "Spent", validationErrors: $expenseStore.validationErrors, validationKey: "amount") {
                LimitedCurrencyField("Spent on?", amount: $editExpense.amount)
                    .focused($focusedField, equals: .amount)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focusNextField($focusedField)
                    }
            }
            VStack(alignment: .leading) {
                DatePicker("Date", selection: $editExpense.date, displayedComponents: .date)
                    .font(.headline)
                    .focused($focusedField, equals: .date)
            }
            typePicker
        }
    }
    
    private var typePicker: some View {
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
    }
    
    private var categorySelection: some View {
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
    
    struct ContentStyle {
        static let Spacing: CGFloat = 20
        static let Opacity: Double = 0.2
        static let FontSize: CGFloat = 22
        
        struct Padding {
            // Popup paddings
            static let PopupVertical: CGFloat = 20
            static let PopupLeading: CGFloat = 24
            static let PopupTrailing: CGFloat = 16
            
            // Inner paddings for buttons
            static let InnerSaveButton: CGFloat = 5
            static let InnerBackButton: CGFloat = 8
        }
    }
}

#Preview {
    ExpenseDetailPopup(onRefresh: {}, expensesStore: ExpensesViewModel())
}
