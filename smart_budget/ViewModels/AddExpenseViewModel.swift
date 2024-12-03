//
//  AddExpenseViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 26/11/2024.
//

import Foundation
import SwiftUICore

class AddExpenseViewModel: ObservableObject {
    @Environment(Router.self) var router: Router
    
    @Published var categories: ViewState<[Categorie]> = .idle
    
    @Published var addExpenseState: ViewState<Bool> = .idle
    @Published var validationErrors: [ValidationError] = []
    
    @Published var shouldNavigate = false
    
    let api = ApiService()
    
    init() {
        fetchCategories()
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
    
    func onSubmitExpense(name: String, amount: Float, date: Date, type: ExpenseType?, category: Categorie?) {
        validationErrors.removeAll()
        if name.isEmpty {
            validationErrors.append(ValidationError(key: "name", message: "Name is required"))
        }
        if type == nil {
            validationErrors.append(ValidationError(key: "type", message: "Type is required"))
        }
        if category == nil {
            validationErrors.append(ValidationError(key: "category", message: "Category is required"))
        }
        
        if validationErrors.count > 0 {
            return
        }
        
        let expense = CreateExpense(name: name, amount: amount, date: date, type: type!, categoryId: category!.id)
        addExpense(expense)
    }
    
    func addExpense(_ expense: CreateExpense) {
        addExpenseState = .loading
        api.post("expenses", body: expense) { [weak self] (result: Result<CreateExpense, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.validationErrors.removeAll()
                    self?.objectWillChange.send()
                    self?.addExpenseState = .success(true)
                    self?.shouldNavigate = true
                case .failure(let error):
                    self?.addExpenseState = .failure(error)
                }
            }
        }
    }
    
}
