//
//  ExpenseDetailViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 29/11/2024.
//

import Foundation

class ExpenseDetailViewModel: ObservableObject {
    @Published var deleteState: ViewState<Bool> = .idle
    
    let api = ApiService()
    
    func deleteExpense(_ expense: Expense) {
        deleteState = .loading
        api.Delete("expense/\(expense.id)") { [weak self] (result: Result<Bool, Error>) in
            switch result {
            case .success:
                self?.deleteState = .success(true)
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
