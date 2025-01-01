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
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            topActionBar
            
            editCategoryForm
            
            LargeButton(
                "Save  Category",
                theme: .primary,
                loading: Binding<Bool?>(
                    get: { categoriesStore.editCategoryState == .loading },
                    set: { _ = $0 }
                )
            ){
                categoriesStore.editCategory()
            }
            .padding(.top, ContentStyle.Padding.SaveButtonTop)
        }
        .onChange(of: categoriesStore.editCategoryState) { _, state in
            if case .success(_) = state {
                Task { await dismissAllPopups() }
            }
        }
        .onChange(of: categoriesStore.deleteCategoryState) { _, state in
            if case .success(_) = state {
                Task { await dismissAllPopups() }
            }
        }
        .padding()
    }
    
    private var topActionBar: some View {
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
                    .padding(ContentStyle.Padding.Icon)
                    .foregroundColor(.danger)
            }
            Button {
                Task { await dismissLastPopup() }
            } label: {
                Image(systemName: "xmark")
                    .padding(ContentStyle.Padding.Icon)
                    .foregroundColor(.primary)
                    .background(.secondary.opacity(ContentStyle.Opacity))
                    .clipShape(.circle)
            }
        }
    }
    
    private var editCategoryForm: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            TextFieldValidationView(
                label: "Category name",
                validationErrors: $categoriesStore.validationErrors,
                validationKey: "name"
            ) {
                TextField("Enter category name", text: Binding(
                    get: { categoriesStore.selectedCategory!.name },
                    set: { categoriesStore.selectedCategory?.name = $0 }
                ))
            }
            
            TextFieldValidationView(label: "Description", validationErrors: $categoriesStore.validationErrors, validationKey: "description") {
                TextField("Enter category description", text: Binding(
                    get: { categoriesStore.selectedCategory!.description ?? "" },
                    set: { categoriesStore.selectedCategory?.description = $0 }
                ))
            }
            
            TextFieldValidationView(label: "Allocated amount", validationErrors: $categoriesStore.validationErrors, validationKey: "amount") {
                LimitedCurrencyField("Max spending for this catergory?", amount: Binding (
                    get: { categoriesStore.selectedCategory!.max_expense ?? 0.0 },
                    set: { categoriesStore.selectedCategory?.max_expense = $0 }
                ))
            }
            
            VStack(alignment: .leading) {
                Text("Category type")
                    .font(.headline)
                Picker("Select category type", selection: Binding(
                    get: { categoriesStore.selectedCategory!.type },
                    set: { categoriesStore.selectedCategory?.type = $0 }
                )) {
                    ForEach(CategoryType.allCases, id: \.self) { categoryType in
                        Text(categoryType.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    struct ContentStyle {
        static let Spacing: CGFloat = 20
        static let Opacity: Double = 0.2
        
        struct Padding {
            static let Icon: CGFloat = 8
            static let SaveButtonTop: CGFloat = 20
        }
    }
}

struct ConfirmDeleteCategoryPopup: CenterPopup {
    let onConfirmDelete: () -> Void
    
    var body: some View {
        VStack(spacing: ContentStyle.Spacing) {
            Text("Are you sure you want to delete this category?")
                .multilineTextAlignment(.center)
            HStack {
                
                LargeButton("Cancel", theme: .secondary){
                    Task { await dismissLastPopup() }
                }
                
                LargeButton("Delete", theme: .warning) {
                    onConfirmDelete()
                }
            }
        }
        .padding(ContentStyle.Padding)
    }
    
    struct ContentStyle {
        static let Spacing: CGFloat = 20
        static let Padding: CGFloat = 30
    }
}

#Preview {
    ConfirmDeleteCategoryPopup(){
        
    }
}
