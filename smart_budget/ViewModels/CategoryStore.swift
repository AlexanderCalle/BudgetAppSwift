//
//  CategorieViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation
import SwiftUI

class CategoryStore: ObservableObject {
    
    @Published var categoriesState: ViewState<[Categorie]> = .idle
    {
        didSet {
            if case .success(let data) = categoriesState {
                self.total_expenses = data.reduce(0.0 as Float) { $0 + ($1.totalExpenses ?? 0) }
                self.total_budgetted = data.reduce(0.0 as Float) { $0 + ($1.max_expense ?? 0) }
                self.total_percentage = (self.total_expenses / self.total_budgetted)
            }
            
        }
    }
    
    @Published var expenseOverview: [DayExpense]
    @Published var total_expenses: Float = 0.0 as Float
    @Published var total_budgetted: Float = 0.0 as Float
    @Published var total_percentage: Float = 0.0 as Float
    @Published var validationErrors: [ValidationError] = []
    
    @Published var isCreatingCategorie: Bool = false
    @Published var isSuccessfullyCreated: Bool = false
    @Published var creatingError: Error?
    
    @Published var selectedCategory: ViewState<Categorie> = .idle

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
    
    func selectCategory(category: Categorie) {
        self.selectedCategory = .success(category)
    }
    
    
    func fetchChartOverview() {
        api.get("expenses/overview") { [weak self] (result: Result<[DayExpense], Error>) in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let chartOverview):
                    self?.expenseOverview = chartOverview
                case .failure(let error):
//                    if let netwerkError = error as? NetworkError {
//
//                    }
//                    if let apiError = error as? ApiError {
//                        self?.expenseOverview = .failure(apiError)
//                    }
                    print(error)
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
