//
//  AddCategoryPopup.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 28/11/2024.
//

import SwiftUI
import MijickPopups

struct AddCategoryPopup: BottomPopup {
    let onCloseAction: () -> Void
    @ObservedObject var categorieStore = AddCategoryViewModel()
    @Environment(Settings.self) var settings: Settings
    
    let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .enableDragGesture(!isLandscape)
    }
    
    var body: some View {
        VStack(spacing: ContentStyle.Spacing) {
            CloseButton { Task { await dismissLastPopup() } }
            Text("Add new category")
                .font(.system(size: ContentStyle.TitleFontSize, weight: .bold))
            
            ScrollView {
                VStack(spacing: ContentStyle.Spacing) {
                    categoryInputs
                    
                    LargeButton(
                        "Save category",
                        theme: .primary,
                        loading: Binding<Bool?> (
                            get: { categorieStore.createdCatergoryState == .loading },
                            set: { _ = $0 }
                        )
                    ) {
                        categorieStore.addNewCategory()
                    }
                    .padding(.top, ContentStyle.Padding.Top)
                }
            }
        }
        .onChange(of: categorieStore.createdCatergoryState) { _, value in
            if case .success(_) = value {
                Task { await dismissLastPopup() }
                onCloseAction()
            }
        }
        .padding(.vertical, ContentStyle.Padding.PopupVertical)
        .padding(.leading, ContentStyle.Padding.PopupLeading)
        .padding(.trailing, ContentStyle.Padding.PopupTrailing)
    }
    
    private var categoryInputs: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            
            TextFieldValidationView(label: "Category name", validationErrors: $categorieStore.validationErrors, validationKey: "name") {
                TextField("Enter category name", text: $categorieStore.name)
            }
            
            TextFieldValidationView(label: "Description", validationErrors: $categorieStore.validationErrors, validationKey: "description") {
                TextField("Enter category description", text: $categorieStore.description)
            }
            
            TextFieldValidationView(label: "Allocated amount", validationErrors: $categorieStore.validationErrors, validationKey: "amount") {
                LimitedCurrencyField("Max spending for this category", amount: $categorieStore.amount)
            }
            
            VStack(alignment: .leading) {
                Text("Category type")
                    .font(.headline)
                Picker("Select category type", selection: $categorieStore.categoryType) {
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
        static let TitleFontSize: CGFloat = 22
        
        struct Padding {
            static let Top: CGFloat = 20
            static let PopupVertical: CGFloat = 20
            static let PopupLeading: CGFloat = 24
            static let PopupTrailing: CGFloat = 16
        }
    }
}

#Preview {
    AddCategoryPopup(onCloseAction: {})
}
