//
//  ContentView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 06/10/2024.
//

import SwiftUI
import Network
import MijickPopups

struct HomeView: View {
    @Environment(Settings.self) var settings: Settings
    
    @ObservedObject var categoriesStore: CategoryStore
    @State private var isConnected = true
    
    var body: some View {
        VStack {
            if (!isConnected) {
                OfflineMessage(networkError: nil)
            } else {
                TopBarView("Dashboard")
                ScrollView {
                    if !categoriesStore.expenseOverview.isEmpty {
                        SevenDaysChartView(categoriesStore.expenseOverview)
                            .frame(height: 200)
                    }
                    VStack {
                        StateViewLoader(state: categoriesStore.categoriesState) { categories in
                            CategoryListView(
                                categoryStore: categoriesStore,
                                categories: categories,
                                onAddCategory: {
                                    Task {
                                        await AddCategoryPopup() { categoriesStore.refreshCategories() }.present()
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .refreshable {
            categoriesStore.fetchCategories()
            categoriesStore.fetchChartOverview()
            checkInternetConnection()
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: .expenseCreated,
                object: nil,
                queue: .main
            ) { _ in
                categoriesStore.refreshCategories()
                categoriesStore.fetchChartOverview()
            }
        }
    }
    
    // Checks if there is an internet connection
    private func checkInternetConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = (path.status == .satisfied)
            }
        }
        let queue = DispatchQueue(label: "InternetMonitor")
        monitor.start(queue: queue)
    }
}

#Preview {
    @Previewable var categoryStore: CategoryStore = CategoryStore()
    HomeView(categoriesStore: categoryStore)
        .registerPopups() { $0
            .center {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .popupHorizontalPadding(20)
            }
            .vertical {
                $0.backgroundColor(.background)
                  .cornerRadius(20)
                  .enableStacking(true)
                  .tapOutsideToDismissPopup(true)
            }
        }
}
