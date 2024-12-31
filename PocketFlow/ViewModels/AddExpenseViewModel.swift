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
    
    // MARK: - Form states
    @Published var name: String = ""
    @Published var date: Date = Date()
    @Published var type: ExpenseType? = nil
    @Published var selectedCategory: Categorie? = nil
    
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
    
    func addExpense(amount: Float) {
        guard validate() else { return }
        addExpenseState = .loading
        
        let expense = CreateExpense(name: name, amount: amount, date: date, type: type!, categoryId: selectedCategory!.id)
        api.post("expenses", body: expense) { [weak self] (result: Result<CreateExpense, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.validationErrors.removeAll()
                    self?.addExpenseState = .success(true)
                    self?.shouldNavigate = true
                    self?.objectWillChange.send()
                case .failure(let error):
                    if let apiError = error as? ApiError {
                        if case .badRequest(let decodedMessage) = apiError {
                            switch(decodedMessage) {
                            case .detailed(let details, _, _):
                                details.forEach { detail in
                                    self?.validationErrors.append(ValidationError(key: detail.property, message: detail.message))
                                }
                                self?.addExpenseState = .failure(apiError)
                            default:
                                self?.addExpenseState = .failure(apiError)
                            }
                        } else {
                            self?.addExpenseState = .failure(apiError)
                        }
                    } else {
                        self?.addExpenseState = .failure(error)
                    }
                }
            }
        }
    }
    
    // MARK: - Validation functions
    private func validate() -> Bool {
        validationErrors.removeAll()
        if name.isEmpty {
            validationErrors.append(ValidationError(key: "name", message: "Name is required"))
        }
        if type == nil {
            validationErrors.append(ValidationError(key: "type", message: "Type is required"))
        }
        if selectedCategory == nil {
            validationErrors.append(ValidationError(key: "category", message: "Category is required"))
        }
        
        return validationErrors.count == 0
    }
}
