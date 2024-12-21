//
//  AddExpenseView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 26/11/2024.
//

import SwiftUI
import MijickPopups

struct AddExpenseView: View {
    @Environment(Router.self) var router
    @Environment(Settings.self) var settings: Settings
    let amount: Float
    
    @StateObject var addExpenseViewModel = AddExpenseViewModel()
    
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var type: ExpenseType? = nil
    @State private var selectedCategory: Categorie? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Grid(alignment: .leading, horizontalSpacing: 50, verticalSpacing: 20) {
                Divider()
                GridRow {
                    Text("For")
                        .font(.headline)
                    TextField("amount spent on?", text: $name)
                }
                if addExpenseViewModel.validationErrors.contains(where: { $0.key == "name" }) {
                    Text(addExpenseViewModel.validationErrors.first(where: { $0.key == "name" })?.message ?? "")
                        .foregroundColor(.danger)
                }
                Divider()
                GridRow {
                    Label("Date", systemImage: "calendar")
                        .font(.headline)
                    Button{
                        Task { await DatePickerPopup(date: $date).present()}
                    } label: {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                    }
                    .foregroundColor(.primary)
                }
                if addExpenseViewModel.validationErrors.contains(where: { $0.key == "date" }) {
                    Text(addExpenseViewModel.validationErrors.first(where: { $0.key == "date" })?.message ?? "")
                        .foregroundColor(.danger)
                }
                Divider()
                GridRow {
                    Label("Type", systemImage: "creditcard.fill")
                    if type != nil {
                        Button {
                            Task { await ExpenseTypeSelectionPopup(SetExpenseType: {
                                type = $0
                            }).present() }
                        } label: {
                            Text(type!.rawValue)
                        }
                        .foregroundColor(.primary)
                    } else {
                        Button {
                            Task { await ExpenseTypeSelectionPopup(SetExpenseType: {
                                type = $0
                            }).present() }
                        } label: {
                            Text("Select expense type")
                        }
                        .foregroundColor(.primary)
                    }
                }
                if addExpenseViewModel.validationErrors.contains(where: { $0.key == "type" }) {
                    Text(addExpenseViewModel.validationErrors.first(where: { $0.key == "type" })?.message ?? "")
                        .foregroundColor(.danger)
                }
                Divider()
            }
            ScrollView() {
                VStack(alignment: .leading) {
                    Text("Category?")
                        .font(.system(size: 20, weight: .medium))
                    if addExpenseViewModel.validationErrors.contains(where: { $0.key == "category" }) {
                        Text(addExpenseViewModel.validationErrors.first(where: { $0.key == "category" })!.message)
                            .foregroundColor(.danger)
                    }
                    switch addExpenseViewModel.categories {
                    case .loading:
                        ProgressView()
                    case .success(let categories):
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(categories) { category in
                                CategorySelectionRow(category: category, isSelected: selectedCategory == category) {
                                    selectedCategory = category
                                }
                            }
                        }
                    case .failure:
                        Text("Error")
                    case .idle:
                        Text("")
                    }
                }
            }
            Button(action: {
                addExpenseViewModel.onSubmitExpense(
                    name: name, amount: amount, date: date, type: type, category: selectedCategory)
            }){
                Group {
                
                    if case .loading = addExpenseViewModel.addExpenseState {
                        ProgressView()
                    } else {
                        Text("Save Expense")
                        
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .onChange(of: addExpenseViewModel.shouldNavigate, perform: { _ in
            if addExpenseViewModel.shouldNavigate {
                router.navigateToRoot()
            }
        })
        .padding()
        //.navigationBarTitle(amount.formatted(.currency(code: "EUR")))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(amount, format: .defaultCurrency(code: settings.currency.rawValue))
                    .font(.headline)
            }
        }
    }
        
}

struct CategorySelectionRow: View {
    let category: Categorie
    let isSelected: Bool
    var remove: (() -> Void)? = nil
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 50) {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(.purple)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
            }
            Text(category.name)
            Spacer()
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(10)
        .onTapGesture {
            if isSelected {
                if let remove {
                    remove()
                }
            } else {
                action()
            }
        }
        .tint(.purple)
    }
}

struct DatePickerPopup: BottomPopup {
    @Binding var date: Date
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: { Task { await dismissLastPopup() }})
                {
                    Image(systemName: "xmark")
                        .padding(8)
                        .background(.secondary.opacity(0.2))
                        .cornerRadius(.infinity)
                        .tint(.primary)
                }

            }
            DatePicker("Select Date", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .tint(.purple)
                .padding()
        }
        .padding(.vertical, 20)
        .padding(.leading, 24)
        .padding(.trailing, 16)
    }
}

struct ExpenseTypeSelectionPopup: BottomPopup {
    let SetExpenseType: (ExpenseType) -> Void
    @State var selectedType: ExpenseType = .card
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: { Task { await dismissLastPopup() }})
                {
                    Image(systemName: "xmark")
                        .padding(8)
                        .background(.secondary.opacity(0.2))
                        .cornerRadius(.infinity)
                        .tint(.primary)
                }
            }
            Spacer()
            Text("Select Expense Type")
                .font(.headline)
            VStack(spacing: 16) {
                ForEach(ExpenseType.allCases, id: \.self) { type in
                    SelectionRow(
                        title: type.rawValue,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                    }
                }
            }
            .padding()

            Button(action: {
                SetExpenseType(selectedType)
                Task { await dismissLastPopup() }
            }) {
                Text("Save and close")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .foregroundColor(.background)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding(.vertical, 20)
        .padding(.leading, 24)
        .padding(.trailing, 16)
    }
}

struct SelectionRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(.purple)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
            }
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(10)
        .onTapGesture {
            onTap()
        }
        .tint(.purple)
    }
}


#Preview {
    AddExpenseView(amount: 25.8)
        .background(Color.background)
        .environment(Router())
        .registerPopups() { $0
            .center {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .popupHorizontalPadding(20)
            }
            .vertical {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .enableStacking(true)
                  .tapOutsideToDismissPopup(true)
            }
        }
}
