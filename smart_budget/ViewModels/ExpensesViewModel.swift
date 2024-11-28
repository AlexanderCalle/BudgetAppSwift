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
    
    func fetchExpenses() {
        print("Fetching expenses")
        expenses = .loading
        var urlString = "expenses"
        if(selectedCategory != nil) {
            urlString += "?category=\(selectedCategory!.id)"
        }
        
        api.Get(urlString) { [weak self] (result: Result<[Expense], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let expensesResult):
                    print("Expenses fetched: \(expensesResult.count)")
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
        print("Fetching expenses")
        categories = .loading
        api.Get("categories") { [weak self] (result: Result<[Categorie], Error>) in
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
    
}
