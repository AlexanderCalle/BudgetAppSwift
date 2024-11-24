//
//  ContentView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 06/10/2024.
//

import SwiftUI
import Network

struct HomeView: View {
    @EnvironmentObject var router: Router
    @StateObject var categoriesStore = HomeViewModel()
    @State private var isConnected = true
    
    var body: some View {
        VStack {
            if (!isConnected) {
                OfflineView(message: "Offline mode")
            } else {
                TopBarView()
                ScrollView {
                    if case .success(let overview) = categoriesStore.expenseOverview {
                        SevenDaysChartView(data: overview)
                            .frame(height: 200)
                    } else {
                        ProgressView()
                            .frame(height: 200)
                    }
                    mainCategoryOverview
                    Divider()
                    VStack {
                        switch categoriesStore.categoriesState {
                        case .success(let data):
                            CategoryListView(categories: data)
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
        .onAppear {
            checkInternetConnection()
        }
    }
    
    var mainCategoryOverview: some View {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Monthly")
                        Text("\(categoriesStore.daysLeftInCurrentMonth()) Days left")
                            .padding(5)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Budgeted")
                        if  case .success(let main) = categoriesStore.mainCategoryState {
                            Text(main.max_expense ?? 0.0, format: .currency(code: "EUR"))
                                .padding(5)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Spent")
                        Group {
                            Text(categoriesStore.total_expenses, format: .currency(code: "EUR"))
                        }
                        .padding(.all, 5)
                        .background(.green.opacity(0.2))
                        .foregroundColor(Color(hex: "#207520"))
                        .cornerRadius(10)
                    }
                }
                .padding(5)
            }
            .padding(.vertical, 10)
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
    @ObservedObject var router = Router()
    HomeView()
        .environmentObject(router)
}
