//
//  CategorieViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation
import SwiftUI

class CategoriesStore: ObservableObject {
    
    @Published var categories: [Categorie] = [] {
        didSet {
            self.total_expenses = categories.reduce(0 as Float) { $0 + ($1.totalExpenses ?? 0) }
        }
    }
    @Published var mainCategory: Categorie? = nil
    
    @Published var total_expenses: Float = 0 as Float
    
    @State var isLoading: Bool = false
        
    let api: ApiService = ApiService()
    
    init() {
        fetchMainCategory()
        fetchCategories()
    }
    
    func fetchMainCategory() {
        print("Getting main category...")
        isLoading = true
        let userId = "cm2ucugv70000tzkzql9986as"
        api.Get("categories/user/\(userId)") { [unowned self] (result: Result<Categorie, Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let mainCategory):
                    self.mainCategory = mainCategory
                case .failure(let error):
                    print(error)
                }
                
            }
        }
    }

    func fetchCategories() {
        print("Getting items...")
        isLoading = true
        api.Get("categories") { [unowned self] (result: Result<[Categorie], Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let categories):
                    print("Fetched categories: \(categories)")
                    self.categories = categories
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
