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
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var amount: Float = 0
    @State private var categoryType = CategoryType.expenses
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: { Task { await dismissLastPopup() }}) { Image(systemName: "xmark")
                        .padding(8)
                        .background(.secondary.opacity(0.2))
                        .cornerRadius(.infinity)
                        .tint(.primary)
                }
            }
            Text("Add new category")
                .font(.system(size: 22, weight: .bold))
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Category name")
                        .font(.headline)
                    TextField("Enter category name", text: $name)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                    if(categorieStore.validationErrors.contains(where: { $0.key == "name" })) {
                        Text(categorieStore.validationErrors.first(where: { $0.key == "name" })?.message ?? "")
                            .foregroundColor(.danger)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.headline)
                    TextField("Enter category description", text: $description)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                }
                VStack(alignment: .leading) {
                    Text("Allocated amount")
                        .font(.headline)
                    HStack(spacing: 10) {
                        Text(settings.currency.getSymbol())
                        LimitedCurrencyField("Max spending for this catergory?", amount: $amount)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                    if(categorieStore.validationErrors.contains(where: { $0.key == "amount" })) {
                        Text(categorieStore.validationErrors.first(where: { $0.key == "amount" })?.message ?? "")
                            .foregroundColor(.danger)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Category type")
                        .font(.headline)
                    Picker("Select category type", selection: $categoryType) {
                        ForEach(CategoryType.allCases, id: \.self) { categoryType in
                            Text(categoryType.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            Button(action: {
                categorieStore.addNewCategory(name: name, description: description, amount: amount, type: categoryType)
            }){
                Group {
                    if case .loading = categorieStore.createdCatergoryState {
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
        .onChange(of: categorieStore.createdCatergoryState) {
            if case .success(_) = categorieStore.createdCatergoryState {
                Task { await dismissLastPopup() }
                onCloseAction()
            }
        }
        .padding(.vertical, 20)
        .padding(.leading, 24)
        .padding(.trailing, 16)
    }
}

#Preview {
    AddCategoryPopup(onCloseAction: {})
}
