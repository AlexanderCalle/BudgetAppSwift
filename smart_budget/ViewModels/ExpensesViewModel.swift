//
//  ExpensesViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import Foundation

class ExpensesViewModel: ObservableObject {
    @Published var expenses: ViewState<[Expense]> = .idle
    
    let api = ApiService()
    
    init() {
        fetchExpenses()
    }
    
    func fetchExpenses() {
        print("Fetching expenses")
        expenses = .loading
        api.Get("expenses") { [weak self] (result: Result<[Expense], Error>) in
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
    
}
