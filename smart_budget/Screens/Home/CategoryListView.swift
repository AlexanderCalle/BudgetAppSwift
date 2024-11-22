//
//  CategoryListView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 22/11/2024.
//

import SwiftUI

struct CategoryListView: View {
    let categories: [Categorie]
    @State var isExpanded: Set<String> = []
    
    init(categories: [Categorie]) {
        self.categories = categories
        self.isExpanded = Set(categories.map(\.self.id))
    }
    
    var body: some View {
        ScrollView {
            ForEach(categories) { category in
                CategoryRow(category: category)
                
            }
        }
    }
    
    private func CategoryRow(category: Categorie) -> some View {
        return Section(
            isExpanded: Binding<Bool> (
                get: {
                    return isExpanded.contains(category.id)
               },
                set: { newValue in
                    
                }
            )
        ){
            if(category.expenses?.isEmpty ?? true) {
                Text("No expenses yet")
            }
            ForEach(category.expenses ?? []) { expense in
                ExpenseRow(expense: expense)
                    .background(Color.blue.opacity(0.1))
                    .padding(.top, 5)
            }
        } header: {
            HStack(
                alignment: .center
            ) {
                Text(category.name)
                    .font(.title2)
                Spacer()
                Button {
                    ExpandClicked(id: category.id)
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded.contains(category.id) ? 0 : -90))
                        .tint(.black)
                }
                .contentTransition(.symbolEffect(.automatic))
            }
            .padding(.top, 20)
            .onTapGesture {
                ExpandClicked(id: category.id)
            }
        }
    }
    
    private func ExpandClicked(id: String) {
        withAnimation(.linear(duration: 0.2)) {
           if(isExpanded.contains(id)) {
               isExpanded.remove(id)
           } else {
               isExpanded.insert(id)
           }
        }
    }
    
    private func ExpenseRow(expense: Expense) -> some View {
        HStack {
            Text(expense.name)
                .font(.headline)
            Spacer()
            Text("\(expense.amount, specifier: "%.2f") €")
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    CategoryListView(categories: [
        Categorie(id: "1", name: "Food", color: "#d9ab2e", expenses: [
            Expense(id: "1", name: "Mc Donalds", amount: 10.5)
        ]),
        Categorie(id: "2", name: "Transport", expenses: []),
        Categorie(id: "3", name: "Healthcare", expenses: []),
    ]).padding()
}
