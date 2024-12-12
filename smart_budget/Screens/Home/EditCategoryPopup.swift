//
//  EditCategoryPopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 08/12/2024.
//

import Foundation
import SwiftUI
import MijickPopups

struct EditCategoryPopup: BottomPopup {
    @ObservedObject var categoriesStore: CategoryStore
    @Environment(Settings.self) var settings: Settings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button {
                    Task {
                        await ConfirmDeleteCategoryPopup{
                            categoriesStore.deleteCategory(categoryId: categoriesStore.selectedCategory?.id ?? "")
                        }.present()
                    }
                } label: {
                    Image(systemName: "trash")
                        .padding(8)
                        .foregroundColor(.danger)
                }
                Button {
                    Task { await dismissLastPopup() }
                } label: {
                    Image(systemName: "xmark")
                        .padding(8)
                        .foregroundColor(.primary)
                        .background(.gray.opacity(0.2))
                        .clipShape(.circle)
                }
            }
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Category name")
                        .font(.headline)
                    TextField("Enter category name", text: Binding(
                        get: { categoriesStore.selectedCategory!.name },
                        set: { categoriesStore.selectedCategory?.name = $0 }
                    ))
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                    if(categoriesStore.validationErrors.contains(where: { $0.key == "name" })) {
                        Text(categoriesStore.validationErrors.first(where: { $0.key == "name" })?.message ?? "")
                            .foregroundColor(.danger)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.headline)
                    TextField("Enter category description", text: Binding(
                        get: { categoriesStore.selectedCategory!.description ?? "" },
                        set: { categoriesStore.selectedCategory?.description = $0 }
                    ))
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                }
                VStack(alignment: .leading) {
                    Text("Allocated amount")
                        .font(.headline)
                    HStack(spacing: 10) {
                        Text(settings.currency.getSymbol())
                        LimitedCurrencyField("Max spending for this catergory?", amount: Binding (
                            get: { categoriesStore.selectedCategory!.max_expense ?? 0.0 },
                            set: { categoriesStore.selectedCategory?.max_expense = $0 }
                        ))
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                    if(categoriesStore.validationErrors.contains(where: { $0.key == "amount" })) {
                        Text(categoriesStore.validationErrors.first(where: { $0.key == "amount" })?.message ?? "")
                            .foregroundColor(.danger)
                    }
                }
            }
            
            Button(action: {
                categoriesStore.editCategory()
            }){
                Group {
                    if case .loading = categoriesStore.editCategoryState {
                        ProgressView()
                    } else {
                        Text("Save Category")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary)
                .foregroundColor(.background)
                .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .onChange(of: categoriesStore.editCategoryState) { state in
            if case .success(_) = state {
                Task { await dismissLastPopup() }
            }
        }
        .onChange(of: categoriesStore.deleteCategoryState) { state in
            if case .success(_) = state {
                Task { await dismissAllPopups()}
            }
        }
        .padding()
    }
}

struct ConfirmDeleteCategoryPopup: CenterPopup {
    
    let onConfirmDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Are you sure you want to delete this category?")
                .multilineTextAlignment(.center)
            HStack {
                Button {
                    Task { await dismissLastPopup() }
                }label: {
                    Text("Cancel")
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(.secondary.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                Button {
                    onConfirmDelete()
                }label: {
                    Text("Delete")
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(.danger)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding(30)
    }
}

#Preview {
    ConfirmDeleteCategoryPopup(){
        
    }
}
