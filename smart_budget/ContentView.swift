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
    @State var selected = 0
    @State private var previousTab = 0
    @State private var direction: TransitionDirection = .none


    var body: some View {
            VStack {
                ZStack {
                        RouterView {
                            HomeView()
                        }
                        .customTransition(selectedTab: selected,
                                          thisTab: 0, previousTab: previousTab, direction: direction)
                    
                        RouterView {
                            ExpensesView()
                        }
                        .customTransition(selectedTab: selected,
                                          thisTab: 1, previousTab: previousTab, direction: direction)

                       VStack {
                           SettingsView()
                       }
                        .customTransition(selectedTab: selected,
                                          thisTab: 2, previousTab: previousTab, direction: direction)

                }
                .sensoryFeedback(.impact(weight: .light), trigger: selected)
                .accentColor(.purple)
                .background(Color.background)
                
                customBottomBar

        }
    }
    
    
    var customBottomBar: some View{
        HStack {
            ForEach(TabbedItems.allCases, id: \.self){ item in
                Spacer()
                Button{
                    previousTab = selected
                    direction = item.rawValue > selected ? .left : .right
                    withAnimation(.spring(duration: 0.25, bounce: 0.3)) {
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
        
        .padding(20)
        .overlay(
            BottomBorder().stroke(.secondary.opacity(0.3), lineWidth: 1)
        )
    }
    
    
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
        Image(systemName: imageName)
            .font(.system(size: 25))
            .foregroundColor(isActive ? .purple : .gray)
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
