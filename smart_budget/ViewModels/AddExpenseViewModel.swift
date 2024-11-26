//
//  AddExpenseViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 26/11/2024.
//

import Foundation

class AddExpenseViewModel: ObservableObject {
    
    @Published var categories: ViewState<[Categorie]> = .idle
    
    let api = ApiService()
    
    init() {
        fetchCategories()
    }
    
    func fetchCategories() {
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
