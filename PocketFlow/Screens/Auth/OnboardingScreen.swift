//
//  OnBoardingScreen.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 02/12/2024.
//

import SwiftUI

struct OnboardingScreen: View {
    @State var selectedTab: Int = 0
    @StateObject var categoriesStore = AddCategoryViewModel()
    
    @State var selectedCategories: [Categorie] = []
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                WelcomTabView()
                    .tag(0)
                FirstCategoryTabView(selectedCategories: $selectedCategories)
                    .tag(1)
                FinishedTabView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 1.0), value: selectedTab)
            .transition(.slide)
            .tint(.purple)
            
            if case .failure(let error) = categoriesStore.categoriesState {
                ErrorMessage(error: error)
            }
            
            Text("\(selectedTab + 1) / 3")
            
            actionButton
        }
        .padding()
    }
    
    var actionButton: some View {
        Button {
            if selectedTab < 2 {
                if selectedTab == 1 && selectedCategories.count > 0 && !categoriesStore.canContinue {
                    categoriesStore.addMultiCategories(categories: selectedCategories)
                } else {
                    selectedTab += 1
                }
            } else {
                Auth.shared.setNewUser(isNewUser: false)
            }
        } label: {
            Group {
                if selectedTab < 2 {
                    if selectedTab == 1 && selectedCategories.count == 0 {
                        Text("Skip")
                    } else {
                        if case .loading = categoriesStore.categoriesState {
                            ProgressView()
                        } else if !categoriesStore.canContinue && selectedCategories.count > 0 {
                            Text("Save")
                        }
                        else {
                            Text("Next")
                        }
                    }
                } else {
                    Text("Finish")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Color.purple)
            .cornerRadius(10)
        }
    }
}

struct WelcomTabView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            Text("Welcome to PocketFlow!")
                .font(.system(size: 30, weight: .bold))
                .padding(.vertical)
            Text("Your account is now set up. You can start adding your expenses and budgets now.")
                .font(.title2)
            Text("Just a few more steps and you're all set!")
                .font(.title3)
            
            Text("Let's get started!")
                .font(.headline)
        }
    }
    
    struct ContentStyle {
        static let Spacing: CGFloat = 20
    }
}

struct FirstCategoryTabView: View {
    @Binding var selectedCategories: [Categorie]
    
    var categories: [Categorie] = [
        Categorie.NewRecommended(name: "Foods and drinks", max_expense: 150),
        Categorie.NewRecommended(name: "Going out", max_expense: 200),
        Categorie.NewRecommended(name: "Shopping", max_expense: 250)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: ContentStyle.Spacing) {
            Text("First category!")
                .font(.system(size: ContentStyle.FontSize, weight: .bold))
            
            Text("Now that your account is set up, you can start by adding some recommended categories.")
                .font(.title3)
            Text("Choose a category to get started or skip this step and add your own.")
                .font(.title3)
            Text("(You can always add more categories later or edit them.)")
                .font(.subheadline)
            Divider()
            recommendedCategories
        }
    }
    
    var recommendedCategories: some View {
        VStack{
            HStack{
                Text("Recommended categories")
                Spacer()
            }
            ScrollView {
                VStack {
                    ForEach(categories) { category in
                        CategorySelectionRow(category: category, isSelected: selectedCategories.contains(where: { $0.name == category.name} ), remove: {
                            selectedCategories.removeAll(where: { $0.name == category.name})
                        }) {
                            selectedCategories.append(category)
                        }
                    }
                }
            }
        }
    }
    
    struct ContentStyle {
        static let Spacing: CGFloat = 20
        static let FontSize: CGFloat = 25
    }
}

struct FinishedTabView: View {
    
    var body: some View {
        VStack {
            Text("🎉")
                .font(.largeTitle)
            Text("Finished!")
                .font(.title)
            Text("You're all set up!")
                .font(.title3)
                .padding()
            Text("Let's get started, press the button below to start your flow!")
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    OnboardingScreen()
        .background(Color.background)
    
}
