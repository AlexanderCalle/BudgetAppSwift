//
//  ContentView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI
import CoreHaptics
import MijickPopups

enum TransitionDirection {
    case none
    case left
    case right
}


struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    @State var selected = 0
    @State private var previousTab = 0
    @State private var direction: TransitionDirection = .none
    
    @ObservedObject var categoryStore = CategoryStore()


    var body: some View {
        VStack(spacing: ContentStyle.SpacingNone) {
            ZStack {
                    HomeView(categoriesStore: categoryStore)
                        .customTransition(
                            selectedTab: selected,
                            thisTab: 0,
                            previousTab: previousTab,
                            direction: direction
                        )
                
                    ExpensesView()
                        .customTransition(
                            selectedTab: selected,
                            thisTab: 1,
                            previousTab: previousTab,
                            direction: direction
                        )

                   SettingsView()
                        .customTransition(
                            selectedTab: selected,
                            thisTab: 2,
                            previousTab: previousTab,
                            direction: direction
                        )

            }
            .background(Color.background)
            customBottomBar
        }
        .fullScreenCover(isPresented: $appState.showAddExpense) {
            addAmountView
        }
        .accentColor(.purple)
    }
    
    
    var customBottomBar: some View{
        HStack {
            ForEach(TabbedItems.allCases, id: \.self){ item in
                Spacer()
                Button{
                    previousTab = selected
                    direction = item.rawValue > selected ? .left : .right
                    withAnimation(ContentStyle.ScreenAnimation) {
                        selected = item.rawValue
                    }
                } label: {
                    CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selected == item.rawValue))
                }
                .sensoryFeedback(.impact(weight: .light), trigger: selected)
                Spacer()
            }
        }
        .background(Color.background)
        .padding(ContentStyle.BottomBarInnerPadding)
        .overlay(
            BottomBorder().stroke(.secondary.opacity(ContentStyle.BorderOpacity), lineWidth: ContentStyle.BorderWidth)
        )
    }
    
    
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
        Image(systemName: imageName)
            .font(.system(size: ContentStyle.IconSize))
            .foregroundColor(isActive ? .purple : .gray)
    }
    
    var addAmountView: some View{
        RouterView {
            AddAmountView()
        }
        .registerPopups() { $0
            .center {
                $0.backgroundColor(.background)
                    .cornerRadius(ContentStyle.PopupCornRadius)
                    .popupHorizontalPadding(ContentStyle.PopupHorPadding)
                    .tapOutsideToDismissPopup(true)
            }
            .vertical {
                $0.backgroundColor(.background)
                    .cornerRadius(ContentStyle.PopupCornRadius)
                    .enableStacking(true)
                    .tapOutsideToDismissPopup(true)
            }
        }
    }
    
    struct ContentStyle {
        static let PopupHorPadding: CGFloat = 20
        static let PopupCornRadius: CGFloat = 20
        
        static let SpacingNone: CGFloat = 0
        
        static let IconSize: CGFloat = 25
        
        static let BorderWidth: CGFloat = 1
        static let BorderOpacity: Double = 0.3
        
        static let BottomBarInnerPadding: CGFloat = 20
        
        static let ScreenAnimation: Animation = Animation.spring(duration: 0.25, bounce: 0.3)
    }
}

struct BottomBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        return path
    }
}

struct CustomTransition: ViewModifier {
    let selectedTab: Int
    let thisTab: Int
    let previousTab: Int
    let direction: TransitionDirection
        
        func body(content: Content) -> some View {
            content
                .opacity(selectedTab == thisTab ? 1 : 0)
                .offset(x: getOffset())
                .zIndex(selectedTab == thisTab ? 1 : 0)
        }
        
        private func getOffset() -> CGFloat {
            let screenWidth = UIScreen.main.bounds.width
            
            if selectedTab == thisTab {
                return 0
            }
            
            switch direction {
            case .left:
                // When going left, the current view exits to the left (-width) and new view enters from the right (+width)
                return thisTab == previousTab ? -screenWidth : screenWidth
            case .right:
                // When going right, the current view exits to the right (+width) and new view enters from the left (-width)
                return thisTab == previousTab ? screenWidth : -screenWidth
            case .none:
                return 0
            }
        }
}

extension View {
    func customTransition(selectedTab: Int, thisTab: Int, previousTab: Int, direction: TransitionDirection) -> some View {
        modifier(CustomTransition(selectedTab: selectedTab,
                                thisTab: thisTab,
                                  previousTab: previousTab,
                                direction: direction))
    }
}


enum TabbedItems: Int, CaseIterable{
    case home = 0
    case expenses
    case settings
    
    var title: String{
        switch self {
        case .home:
            return "Home"
        case .expenses:
            return "Expenses"
        case .settings:
            return "Settings"
        }
    }
    
    var iconName: String{
        switch self {
        case .home:
            return "house"
        case .expenses:
            return "creditcard"
        case .settings:
            return "gearshape"
        }
    }
}



#Preview {
    ContentView()
        .environmentObject(AppState())
        .environment(Settings())
        .registerPopups() { $0
            .center {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .popupHorizontalPadding(20)
                  .tapOutsideToDismissPopup(true)
            }
            .vertical {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .enableStacking(true)
                  .tapOutsideToDismissPopup(true)
                  
            }
        }
}
