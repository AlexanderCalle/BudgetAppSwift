//
//  CategorieViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 21/11/2024.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var categoriesState: ViewState<[Categorie]> = .idle
    {
        didSet {
            if case .success(let data) = categoriesState {
                self.total_expenses = data.reduce(0.0 as Float) { $0 + ($1.totalExpenses ?? 0) }
            }
            
        }
    }
    
    

    @Published var mainCategoryState: ViewState<Categorie> = .idle
    @Published var expenseOverview: [DayExpense]
    @Published var total_expenses: Float = 0.0 as Float
            
    let api: ApiService = ApiService()
    
    init() {
        let today = Date()
        let calendar = Calendar.current

        let dayExpenses: [DayExpense] = (0...7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            return DayExpense(date: date, value: 0)
        }

        expenseOverview = dayExpenses
        fetchMainCategory()
        fetchCategories()
        fetchChartOverview()
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
        api.Get("categories?expenses=true") { [weak self] (result: Result<[Categorie], Error>) in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let categories):
                    print("Fetched categories: \(categories.map { $0.totalPercentage })")
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
    
    func fetchChartOverview() {
        print("Getting overview...")
        api.Get("expenses/overview") { [weak self] (result: Result<[DayExpense], Error>) in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let chartOverview):
                    print("Fetched chart overview: \(chartOverview)")
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

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
}
