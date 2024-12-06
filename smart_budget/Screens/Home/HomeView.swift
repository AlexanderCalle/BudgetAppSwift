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
    @Environment(Router.self) var router: Router
    @StateObject var categoriesStore = HomeViewModel()
    @State private var isConnected = true
    
    var body: some View {
        VStack {
            if (!isConnected) {
                OfflineView(message: "Offline mode")
            } else {
                TopBarView()
                ScrollView {
                    if !categoriesStore.expenseOverview.isEmpty {
                        SevenDaysChartView(categoriesStore.expenseOverview)
                            .frame(height: 200)
                    }
                    
                    mainCategoryOverview
                    VStack {
                        switch categoriesStore.categoriesState {
                        case .success(let data):
                            CategoryListView(
                                categoryStore: categoriesStore, categories: data, onAddCategory: {
                                    Task { await AddCategoryPopup() {
                                        categoriesStore.fetchCategories()
                                    }.present() }
                                }
                            )
                        case .loading:
                            ProgressView()
                        case .failure(let error):
                            if let error = error as? NetworkError {
                                OfflineView(networkError: error)
                            } else {
                                Text(error.localizedDescription)
                            }
                        case .idle:
                            Text("")
                        }
                    }
                }
            }
        }
        .padding()
        .refreshable {
            categoriesStore.fetchCategories()
            categoriesStore.fetchChartOverview()
            checkInternetConnection()
        }
        .onAppear {
            categoriesStore.fetchCategories()
            categoriesStore.fetchChartOverview()
            checkInternetConnection()
        }
    }
    
    var mainCategoryOverview: some View {
        VStack {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), alignment: .leading),
                    GridItem(.fixed(80), alignment: .trailing),
                    GridItem(.fixed(80), alignment: .trailing)
                ],
                spacing: 5 // Row spacing
            ) {
                Text("Monthly")
                Text("Budgeted")
                Text("Spent")
                Text("\(categoriesStore.daysLeftInCurrentMonth()) Days left")
                Text(categoriesStore.total_budgetted, format: .currency(code: "EUR"))
                Text(categoriesStore.total_expenses, format: .currency(code: "EUR"))
            }
            .padding(10)
            .font(.subheadline)
            .foregroundColor(.primary.opacity(0.7))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.1))
                    .stroke(.secondary.opacity(0.2), lineWidth: 2)
            }
        }
        .padding(.horizontal, 1)
    }
    
    private func OfflineView(networkError: NetworkError?) -> some View {
        if let networkError {
            switch networkError {
            case .invalidURL:
                OfflineView(message: "Api url is invalid")
            case .noInternet:
                OfflineView(message: "No internet connection")
            case .timeout:
                OfflineView(message: "Timeout")
            case .unReachable:
                OfflineView(message: "Server unreachable")
            case .interalError:
                OfflineView(message: "Internal error")
            @unknown default:
                OfflineView(message: "Unknown error")
            }
        } else {
            OfflineView(message: "No internet connection")
        }
    }
    
    private func OfflineView(message: String) -> some View {
        HStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle")
            Text(message)
                .font(.headline)
                .padding()
        }
    }
    
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
    HomeView()
        .environment(Router())
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
