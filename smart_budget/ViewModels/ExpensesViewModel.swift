//
//  ExpensesViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import Foundation

class ExpensesViewModel: ObservableObject {
    @Published var expenses: ViewState<[Expense]> = .idle
    @Published var categories: ViewState<[Categorie]> = .idle
    @Published var selectedCategory: Categorie? = nil
    @Published var selectedExpense: Expense? = nil
    
    @Published var shouldRefresh = false
    @Published var deleteState: ViewState<Bool> = .idle
    @Published var editState: ViewState<Bool> = .idle
    @Published var validationErrors: [ValidationError] = []
    
    let api = ApiService()
    
    init() {
        fetchExpenses()
        fetchCategories()
    }
    
    init(selectedCategory: Categorie?) {
        self.selectedCategory = selectedCategory
        fetchExpenses()
        fetchCategories()
    }
    
    func SelectCategory(_ category: Categorie?) {
        selectedCategory = category
        fetchExpenses()
    }
    
    func SelectExpense(_ expense: Expense) {
        selectedExpense = expense
    }
    
    func updateSelectedExpense(_ newExpense: CreateExpense) {
        self.selectedExpense?.amount = newExpense.amount
        self.selectedExpense?.name = newExpense.name
        self.selectedExpense?.type = newExpense.type
        if case .success(let categoriesList) = categories {
            self.selectedExpense?.category = categoriesList.first(where: { $0.id == newExpense.categoryId })
        }
        self.selectedExpense?.date = newExpense.date
    }
    
    func fetchExpenses() {
        expenses = .loading
        var urlString = "expenses"
        if(selectedCategory != nil) {
            urlString += "?category=\(selectedCategory!.id)"
        }
        
        api.get(urlString) { [weak self] (result: Result<[Expense], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let expensesResult):
                    self?.expenses = .success(expensesResult)
                case .failure(let error):
                    if let netwerkError = error as? NetworkError {
                        self?.expenses = .failure(netwerkError)
                    }
                    if let apiError = error as? ApiError {
                        self?.expenses = .failure(apiError)
                    }
                    print(error)
                }
            }
        }
    }
    
    func fetchCategories() {
        categories = .loading
        api.get("categories") { [weak self] (result: Result<[Categorie], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let categoriesResult):
                    self?.categories = .success(categoriesResult)
                case .failure(let error):
                    if let netwerkError = error as? NetworkError {
                        self?.categories = .failure(netwerkError)
                    }
                    if let apiError = error as? ApiError {
                        self?.categories = .failure(apiError)
                    }
                    print(error)
                }
            }
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        deleteState = .loading
        print("deleting expense")
        api.delete("expenses/\(expense.id)") { [weak self] (result: Result<Bool, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.deleteState = .success(true)
                    self?.fetchExpenses()
                case .failure(let error):
                    if let error = error as? ApiError {
                        self?.deleteState = .failure(error)
                    }
                    if let error = error as? NetworkError {
                        self?.deleteState = .failure(error)
                    } else {
                        self?.deleteState = .failure(error)
                    }
                }
            }
        }
    }
    
    func editExpense(id: String, name: String, amount: Float, date: Date, type: ExpenseType, category: Categorie) {
        guard let expense = validate(name: name, amount: amount, date: date, type: type, category: category) else {
            return
        }

        print("Edit Expense")
        editState = .loading
        
        api.put("expenses/\(id)", body: expense) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newExpense):
                    self?.editState = .success(true)
                    self?.updateSelectedExpense(newExpense)
                    self?.fetchExpenses()
                case .failure(let error):
                    if let netwerkError = error as? NetworkError {
                        self?.editState = .failure(netwerkError)
                    } else if let apiError = error as? ApiError {
                        self?.editState = .failure(apiError)
                    } else {
                        self?.editState = .failure(error)
                    }
                }
            }
        }
    }
    
    private func validate(name: String, amount: Float, date: Date, type: ExpenseType, category: Categorie) -> CreateExpense? {
        validationErrors.removeAll()
        if name.isEmpty {
            validationErrors.append(ValidationError(key: "name", message: "Name is required"))
        }
        
        if amount.isNaN {
            validationErrors.append(ValidationError(key: "amount", message: "Amount is required"))
        } else {
            if amount < 0 {
                validationErrors.append(ValidationError(key: "amount", message: "Amount must be positive"))
            }
        }
        
        if validationErrors.count == 0 {
            return CreateExpense(name: name, amount: amount, date: date, type: type, categoryId: category.id)
        } else {
            return nil
        }
    }
    
}
