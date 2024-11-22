//
//  CategorieViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation
import SwiftUI

class CategoriesStore: ObservableObject {
    
    @Published var categoriesState: ViewState<[Categorie]> = .idle
    {
        didSet {
            if case .success(let data) = categoriesState {
                self.total_expenses = data.reduce(0 as Float) { $0 + ($1.totalExpenses ?? 0) }
            }
            
        }
    }
    @Published var mainCategoryState: ViewState<Categorie> = .idle
    @Published var total_expenses: Float = 0 as Float
            
    let api: ApiService = ApiService()
    
    init() {
        fetchMainCategory()
        fetchCategories()
    }
    
    func fetchMainCategory() {
        print("Getting main category...")
        mainCategoryState = .loading
        let userId = "cm2ucugv70000tzkzql9986as"
        api.Get("categories/user/\(userId)") { [weak self] (result: Result<Categorie, Error>) in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let mainCategory):
                    self?.mainCategoryState = .success(mainCategory)
                case .failure(let error):
                    if let netwerkError = error as? NetworkError {
                        self?.mainCategoryState = .failure(netwerkError)
                    }
                    if let apiError = error as? ApiError {
                        self?.mainCategoryState = .failure(apiError)
                    }
                    print(error)
                }
            }
        }
    }

    func fetchCategories() {
        print("Getting items...")
        categoriesState = .loading
        api.Get("categories") { [weak self] (result: Result<[Categorie], Error>) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                
                switch result {
                case .success(let categories):
                    print("Fetched categories: \(categories)")
                    self?.categoriesState = .success(categories)
                case .failure(let error):
                    if let netwerkError = error as? NetworkError {
                        self?.categoriesState = .failure(netwerkError)
                    }
                    if let apiError = error as? ApiError {
                        self?.categoriesState = .failure(apiError)
                    }
                    print(error)
                }
            }
        }
    }
}

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
}
