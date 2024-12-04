//
//  CategoryListView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 22/11/2024.
//

import SwiftUI

struct CategoryListView: View {
    var categories: [Categorie]
    var onAddCategory: () -> Void
    @State var isExpanded: Set<String> = []
    
    init(_ categories: [Categorie], onAddCategory: @escaping () -> Void) {
        self.categories = categories
        self.onAddCategory = onAddCategory
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Categories")
                    .font(.title)
                Spacer()
            }
            
            ForEach(categories) { category in
                CategoryRow(category: category)
                Divider()
            }
            Button {
                onAddCategory()
            } label: {
                Label("Add Category", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .tint(.gray)
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 1)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundColor(.gray)
            }
            .tint(.gray)
            }
        }
    }
    
    private func CategoryRow(category: Categorie) -> some View {
        VStack {
            CategoryDisclosureGroup(category: category)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
    }
    
    
}

struct CategoryDisclosureGroup: View {
    @Environment(Router.self) var router: Router
    let category : Categorie
    @State var isExpanded: Bool = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded
        ){
            HStack {
                Text("Latest Expenses:")
                    .font(.headline)
                Spacer()
            }
            if(category.expenses?.isEmpty ?? true) {
                Text("No expenses yet")
                    .fontWeight(.light)
                    .tint(.gray)
            } else {
                ForEach(category.expenses ?? []) { expense in
                    ExpenseRow(expense: expense)
                        .padding(.top, 5)
                }
                Button {
                    Task { await CategoryDetailPopup(category: category).present() }
                } label: {
                    HStack{
                        Text("See more")
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 2)
                        Image(systemName: "arrow.right")
                            .tint(.gray)
                    }
                }
                .cornerRadius(5)
            }
            
            
        } label: {
                HStack(
                    alignment: .center
                ){
                    Text(category.name)
                        .font(.title3)
                    Spacer()
                    Text(category.max_expense ?? 0, format: .currency(code: "EUR"))
                    Spacer()
                    Group {
                        Text(category.totalExpenses ?? 0, format: .currency(code: "EUR"))
                    }
                    .padding(.all, 5)
                    .foregroundColor(category.totalPercentage < 0.7 ? .successForeground : category.totalPercentage < 0.9 ? .warningForeground : .dangerForeground
                    )
                    .background(category.totalPercentage < 0.7 ? .successBackground : category.totalPercentage < 0.9 ? .warningBackground : .dangerBackground)
                    .cornerRadius(10)
                }
                .onTapGesture {
                    ExpandClicked()
                }
        }
        .tint(Color.primary)
    }
    
    private func ExpandClicked() {
        withAnimation(.easeInOut(duration: 0.4)) {
            isExpanded.toggle()
        }
    }
    
    private func ExpenseRow(expense: Expense) -> some View {
        HStack {
            Text(expense.name)
            Spacer()
            Text("\(expense.amount, specifier: "%.2f") €")
                .font(.headline)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
    }
}

#Preview {
    CategoryListView([
        Categorie(id: "1", name: "Food", max_expense: 100, expenses: [
            Expense(id: "1", name: "Mc Donalds", amount: 10.5, date: Date(), type: .cash),
            Expense(id: "2", name: "Delhaize", amount: 23.34, date: Date(), type: .card)
        ], totalExpenses: 10.5),
        Categorie(id: "2", name: "Transport", expenses: []),
        Categorie(id: "3", name: "Healthcare", expenses: []),
    ]){
        
    }.padding()
        .environment(Router())
}
