//
//  CategorieViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation
import SwiftUI

class CategoryStore: ObservableObject {
    
    // MARK: -- Home states
    @Published var categoriesState: ViewState<[Categorie]> = .idle
    {
        didSet {
            if case .success(let data) = categoriesState {
                self.categories = data
                self.total_expenses = data.reduce(0.0 as Float) { $0 + ($1.totalExpenses ?? 0) }
                self.total_budgetted = data.reduce(0.0 as Float) { $0 + ($1.max_expense ?? 0) }
                self.total_percentage = (self.total_expenses / self.total_budgetted)
            }
            
        }
    }
    @Published var categories: [Categorie] = []
    @Published var expenseOverview: [DayExpense]
    @Published var total_expenses: Float = 0.0 as Float
    @Published var total_budgetted: Float = 0.0 as Float
    @Published var total_percentage: Float = 0.0 as Float
    @Published var validationErrors: [ValidationError] = []
    
    // MARK: -- Add categories States
    @Published var isCreatingCategorie: Bool = false
    @Published var isSuccessfullyCreated: Bool = false
    @Published var creatingError: Error?
    
    // MARK: -- edit/delete states
    @Published var selectedCategory: Categorie? = nil
    @Published var deleteCategoryState: ViewState<Bool> = .idle
    @Published var editCategoryState: ViewState<Bool> = .idle

    let api: ApiService = ApiService()
    
    init() {
        let today = Date()
        let calendar = Calendar.current

        let dayExpenses: [DayExpense] = (0...7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            return DayExpense(date: date, value: 0)
        }

        expenseOverview = dayExpenses
        fetchCategories()
        fetchChartOverview()
    }

    func fetchCategories() {
        categoriesState = .loading
        api.get("categories?expenses=true") { [weak self] (result: Result<[Categorie], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categoriesState = .success(categories)
                case .failure(let error):
                    if let netwerkError = error as? NetworkError {
                        print(netwerkError.self)
                        self?.categoriesState = .failure(netwerkError)
                    }
                    if let apiError = error as? ApiError {
                        self?.categoriesState = .failure(apiError)
                    }
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func refreshCategories() {
        api.get("categories?expenses=true") { [weak self] (result: Result<[Categorie], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categoriesState = .success(categories)
                case .failure(let error):
                    if let netwerkError = error as? NetworkError {
                        print(netwerkError.self)
                        self?.categoriesState = .failure(netwerkError)
                    }
                    if let apiError = error as? ApiError {
                        self?.categoriesState = .failure(apiError)
                    }
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func selectCategory(category: Categorie) {
        self.selectedCategory = category
    }
    
    func fetchChartOverview() {
        api.get("expenses/overview") { [weak self] (result: Result<[DayExpense], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let chartOverview):
                    self?.expenseOverview = chartOverview
                case .failure(let error):
                    self?.expenseOverview = []
                    print(error)
                }
            }
        }
    }
    
    func editCategory() {
        guard validateForm(
            name: selectedCategory?.name ?? "",
            description: selectedCategory?.description ?? "",
            amount: selectedCategory?.max_expense
        ) else {
            return
        }
        
        editCategoryState = .loading
    
        let newCategory = CreateEditCategorie(name: selectedCategory!.name, description: selectedCategory!.description, max_expense: selectedCategory!.max_expense!, type: selectedCategory!.type)
        
        api.put("categories/\(selectedCategory?.id ?? "")", body: newCategory) { [weak self] result in
            DispatchQueue.main.async {
                switch(result) {
                case .success(_):
                    self?.editCategoryState = .success(true)
                    self?.refreshCategories()
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        self?.editCategoryState = .failure(networkError)
                    }
                    if let apiError = error as? ApiError {
                        if case .badRequest(let decodedMessage) = apiError {
                            switch(decodedMessage) {
                            case .detailed(let details, _, _):
                                details.forEach { detail in
                                    self?.validationErrors.append(ValidationError(key: detail.property, message: detail.message))
                                }
                                self?.editCategoryState = .failure(apiError)
                            default:
                                self?.editCategoryState = .failure(apiError)
                            }
                        } else {
                            self?.editCategoryState = .failure(apiError)
                        }
                    } else {
                        self?.editCategoryState = .failure(error)
                    }
                }
            }
        }
    }
    
    func deleteCategory(categoryId: String) {
        deleteCategoryState = .loading
        
        api.delete("categories/\(categoryId)") { [weak self] result in
            DispatchQueue.main.async {
                switch(result) {
                    case.success(_):
                        self?.deleteCategoryState = .success(true)
                        self?.refreshCategories()
                    case .failure(let error):
                        if let networkError = error as? NetworkError {
                            self?.deleteCategoryState = .failure(networkError)
                        }
                        if let apiError = error as? ApiError {
                            self?.deleteCategoryState = .failure(apiError)
                        } else {
                            self?.deleteCategoryState = .failure(error)
                        }
                }
            }
        }
    }
    
    func daysLeftInCurrentMonth() -> Int {
        let calendar = Calendar.current
        let today = Date()
                guard let rangeOfDays = calendar.range(of: .day, in: .month, for: today) else {
            return 0
        }
        
        let currentDay = calendar.component(.day, from: today)
        
        let totalDays = rangeOfDays.count
        let daysLeft = totalDays - currentDay
        
        return daysLeft
    }
    
    private func validateForm(name: String, description: String, amount: Float?) -> Bool {
        validationErrors.removeAll()
        if(name.isEmpty) {
            validationErrors.append(ValidationError(key: "name", message: "Name is required"))
        } else {
            if name.count < 2 {
                validationErrors.append(ValidationError(key: "name", message: "Name must be at least 2 characters"))
            }
            if name.count > 50 {
                validationErrors.append(ValidationError(key: "name", message: "Name must be less than 50 characters"))
            }
        }
        if let amount = amount {
            if(amount < 0) {
                validationErrors.append(ValidationError(key: "amount", message: "Amount must be positive"))
            }
            if amount == 0 {
                validationErrors.append(ValidationError(key: "amount", message: "Cannot be zero"))
            }
        } else {
            validationErrors.append(ValidationError(key: "amount", message: "Amount is required"))
        }
        
        return validationErrors.count == 0
    }
}

enum ViewState<T>: Equatable {
    case idle
    case loading
    case success(T)
    case failure(Error)
    
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch(lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.success(_), .success(_)):
            return true
        case (.failure, .failure):
            return true
        default:
            return false
        }
    }
}
