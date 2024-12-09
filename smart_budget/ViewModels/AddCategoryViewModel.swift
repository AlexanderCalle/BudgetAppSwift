//
//  AddCategoryViewModel.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 28/11/2024.
//

import Foundation

class AddCategoryViewModel: ObservableObject {
    @Published var createdCatergoryState: ViewState<Bool> = .idle
    @Published var validationErrors: [ValidationError] = []
    
    @Published var categoriesState: ViewState<Bool> = .idle
    @Published var canContinue: Bool = false
    
    let api = ApiService()
    
    func addNewCategory(name: String, description: String, amount: Float?) {
        print("Adding new category...")
        guard !validateForm(name: name, description: description, amount: amount) else {
            print("Validation failed.")
            print(validationErrors)
            return
        }
        
        createdCatergoryState = .loading
        let newCategory = CreateEditCategorie(name: name, description: description, max_expense: amount!)
        
        api.post("categories", body: newCategory) { [weak self] (result: Result<CreateEditCategorie, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("Successfully added new category.")
                    self?.createdCatergoryState = .success(true)
                case .failure(let error):
                    if let netwerkError = error as? NetworkError {
                        self?.createdCatergoryState = .failure(netwerkError)
                    } 
                    if let apiError = error as? ApiError {
                        if case .badRequest(let decodedMessage) = apiError {
                            switch(decodedMessage) {
                            case .detailed(let details, _, _):
                                details.forEach { detail in
                                    self?.validationErrors.append(ValidationError(key: detail.property, message: detail.message))
                                }
                                self?.createdCatergoryState = .failure(apiError)
                            default:
                                self?.createdCatergoryState = .failure(apiError)
                            }
                        } else {
                            self?.createdCatergoryState = .failure(apiError)
                        }
                    }
                }
            }
        }
        
    }
    
    func addMultiCategories(categories: [Categorie]) {
        canContinue = false
        categoriesState = .loading
        categories.forEach { addNewCategory(name: $0.name, description: $0.description ?? "", amount: $0.max_expense) }
        
        if validationErrors.count == 0 {
            categoriesState = .success(true)
            canContinue = true  
        } else {
            categoriesState = .failure(NetworkError.interalError)
        }
    }
    
    private func validateForm(name: String, description: String, amount: Float?) -> Bool {
        validationErrors.removeAll()
        if(name.isEmpty) {
            validationErrors.append(ValidationError(key: "name", message: "Name is required"))
        } else {
            if name.count < 2 {
                validationErrors.append(ValidationError(key: "name", message: "Name must be at least 2 characters"))
            }
            if name.count > 50 {
                validationErrors.append(ValidationError(key: "name", message: "Name must be less than 50 characters"))
            }
        }
        if let amount = amount {
            if(amount < 0) {
                validationErrors.append(ValidationError(key: "amount", message: "Amount must be positive"))
            }
            if amount == 0 {
                validationErrors.append(ValidationError(key: "amount", message: "Cannot be zero"))
            }
        } else {
            validationErrors.append(ValidationError(key: "amount", message: "Amount is required"))
        }
        
        return validationErrors.count > 0
    }
}
