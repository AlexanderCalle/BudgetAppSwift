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
    //@StateObject var categoriesStore: CategoryStore
    @State var name = ""
    @State var amount: Float = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(13)
                        .foregroundColor(.primary)
                        .background(.gray.opacity(0.2))
                        .clipShape(.circle)
                }
                Button {
                    
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
                    TextField("Enter category name", text: $name)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
//                    if(categorieStore.validationErrors.contains(where: { $0.key == "name" })) {
//                        Text(categorieStore.validationErrors.first(where: { $0.key == "name" })?.message ?? "")
//                            .foregroundColor(.danger)
//                    }
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.headline)
                    TextField("Enter category description", text: $name)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                }
                VStack(alignment: .leading) {
                    Text("Allocated amount")
                        .font(.headline)
                    HStack(spacing: 10) {
                        Text("€")
                        LimitedCurrencyField("Max spending for this catergory?", amount: $amount)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
//                    if(categorieStore.validationErrors.contains(where: { $0.key == "amount" })) {
//                        Text(categorieStore.validationErrors.first(where: { $0.key == "amount" })?.message ?? "")
//                            .foregroundColor(.danger)
//                    }
                }
            }
            
            Button(action: {
//                categorieStore.addNewCategory(name: name, description: description, amount: amount)
            }){
                Group {
//                    if case .loading = categorieStore.createdCatergoryState {
//                        ProgressView()
//                    } else {
                        Text("Save Category")
//                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary)
                .foregroundColor(.background)
                .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

#Preview {
    EditCategoryPopup()
}
