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
    @EnvironmentObject var appState: AppState
    let amount: Float
    
    @StateObject var addExpenseViewModel = AddExpenseViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing.Medium) {
            ScrollView {
                VStack {
                    expenseForm
                    selectCategory
                }
            }
            LargeButton(
                "Save Expense",
                theme: .purple,
                loading: Binding<Bool?>(
                    get: { addExpenseViewModel.addExpenseState == .loading },
                    set: { _ = $0 }
                )
            ) {
                addExpenseViewModel.addExpense(amount: amount)
            }
            .padding(.top, ContentStyle.Spacing.Medium)
        }
        .onChange(of: addExpenseViewModel.shouldNavigate) { _, value in
            if value {
                // Sends message to notify a fetch request
                NotificationCenter.default.post(name: .expenseCreated, object: nil)
                appState.showAddExpense = false
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(amount, format: .defaultCurrency(code: settings.currency.rawValue))
                    .font(.headline)
            }
        }
    }
    
    private var expenseForm: some View {
        Grid(alignment: .leading, horizontalSpacing: ContentStyle.Spacing.Large, verticalSpacing: ContentStyle.Spacing.Medium) {
            Divider()
            GridRow {
                Text("For")
                    .font(.headline)
                TextField("amount spent on?", text: $addExpenseViewModel.name)
            }
            ValidationMessage(validationErrors: $addExpenseViewModel.validationErrors, validationKey: "name")
            Divider()
            GridRow {
                Label("Date", systemImage: "calendar")
                    .font(.headline)
                Button{
                    Task { await DatePickerPopup(date: $addExpenseViewModel.date).present()}
                } label: {
                    Text(addExpenseViewModel.date.formatted(date: .abbreviated, time: .omitted))
                }
                .foregroundColor(.primary)
            }
            ValidationMessage(validationErrors: $addExpenseViewModel.validationErrors, validationKey: "date")

            Divider()
            GridRow {
                Label("Type", systemImage: "creditcard.fill")
                Button {
                    Task { await ExpenseTypeSelectionPopup(SetExpenseType: { addExpenseViewModel.type = $0 }).present() }
                } label: {
                    Text(addExpenseViewModel.type != nil ? addExpenseViewModel.type!.rawValue : "Select expense type")
                }
                .foregroundColor(.primary)
            }
            ValidationMessage(validationErrors: $addExpenseViewModel.validationErrors, validationKey: "type")
            Divider()
        }
    }
    
    private var selectCategory: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                Text("Category?")
                    .font(.system(size: ContentStyle.FontSize, weight: .medium))
                ValidationMessage(validationErrors: $addExpenseViewModel.validationErrors, validationKey: "category")
        
                switch addExpenseViewModel.categories {
                case .loading:
                    ProgressView()
                case .success(let categories):
                    categoriesList(categories: categories)
                case .failure(let error):
                    ErrorMessage(error: error)
                case .idle:
                    Text("")
                }
            }
        }
    }
    
    private func categoriesList(categories: [Categorie]) -> some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing.Small) {
            ForEach(categories.group(by: { $0.type }).sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) {key, value in
                Text(key.rawValue)
                    .padding(.top, ContentStyle.Spacing.Small)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(value) { category in
                    CategorySelectionRow(category: category, isSelected: addExpenseViewModel.selectedCategory == category) {
                        addExpenseViewModel.selectedCategory = category
                    }
                }
            }
        }
    }
    
    struct ContentStyle {
        struct Spacing {
            static let Small: CGFloat = 10
            static let Medium: CGFloat = 20
            static let Large: CGFloat = 50
        }
        
        static let FontSize: CGFloat = 20
        
        struct Padding {
            static let Small: CGFloat = 15
            static let Medium: CGFloat = 20
        }
    }
        
}

struct CategorySelectionRow: View {
    let category: Categorie
    let isSelected: Bool
    var remove: (() -> Void)? = nil
    let action: () -> Void
    
    var body: some View {
        Button{
            !isSelected ? action() : remove != nil ? remove!() : ()
        }label: {
            HStack(spacing: ContentStyle.Spacing) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .foregroundColor(isSelected ? .purple : .gray)
                    .frame(width: ContentStyle.Size, height: ContentStyle.Size)
                Text(category.name)
                Spacer()
            }
        }
        .tint(.primary)
        .padding()
        .background(isSelected ? Color.gray.opacity(ContentStyle.Opacity) : Color.clear)
        .cornerRadius(ContentStyle.CornerRadius)
    }
    
    struct ContentStyle {
        static let Spacing: CGFloat = 50
        static let Size: CGFloat = 20
        static let Opacity: Double = 0.2
        static let CornerRadius: CGFloat = 10
    }
}

struct DatePickerPopup: BottomPopup {
    @Binding var date: Date
    
    var body: some View {
        VStack(spacing: ContentStyle.Spacing) {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            
            DatePicker("Select Date", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .tint(.purple)
                .padding()
        }
        .padding(.vertical, ContentStyle.Padding.Vertical)
        .padding(.leading, ContentStyle.Padding.Leading)
        .padding(.trailing, ContentStyle.Padding.Trailing)
    }
    
    struct ContentStyle {
        static let Spacing: CGFloat = 20
        struct Padding {
            static let Leading: CGFloat = 24
            static let Trailing: CGFloat = 16
            static let Vertical: CGFloat = 20
        }
    }
}

struct ExpenseTypeSelectionPopup: BottomPopup {
    let SetExpenseType: (ExpenseType) -> Void
    @State var selectedType: ExpenseType = .card
    
    var body: some View {
        VStack(spacing: ContentStyle.Spacing.None) {
            CloseButton {
                Task { await dismissLastPopup() }
            }
            
            Spacer()
            Text("Select Expense Type")
                .font(.headline)
            VStack(spacing: ContentStyle.Spacing.Default) {
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
            
            LargeButton(
                "Save and Close",
                theme: .primary
            ) {
                SetExpenseType(selectedType)
                Task { await dismissLastPopup() }
            }
            .padding(.top, ContentStyle.Padding.Vertical)
        }
        .padding(.vertical, ContentStyle.Padding.Vertical)
        .padding(.leading, ContentStyle.Padding.Leading)
        .padding(.trailing, ContentStyle.Padding.Trailing)
    }
    
    struct ContentStyle {
        struct Spacing {
            static let None: CGFloat = 0
            static let Default: CGFloat = 20
        }
        struct Padding {
            static let Leading: CGFloat = 24
            static let Trailing: CGFloat = 16
            static let Vertical: CGFloat = 20
        }
    }
}

struct SelectionRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button{
            onTap()
        } label: {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .resizable()
                .foregroundColor(isSelected ? .purple : .gray)
                .frame(width: ContentStyle.Size, height: ContentStyle.Size)
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(ContentStyle.Opacity) : Color.clear)
        .cornerRadius(ContentStyle.CornerRadius)
        .tint(.purple)
    }
    
    struct ContentStyle {
        static let Size: CGFloat = 20
        static let CornerRadius: CGFloat = 10
        static let Opacity: Double = 0.2
    }
}

// Extension for the notification name of created expense type
extension Notification.Name {
    static let expenseCreated = Notification.Name("expenseCreated")
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
