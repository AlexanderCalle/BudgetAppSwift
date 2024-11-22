//
//  ContentView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 06/10/2024.
//

import SwiftUI
import Network

struct HomeView: View {
    @StateObject var categoriesStore = CategoriesStore()
    @State private var isConnected = true
    
    var body: some View {
        VStack {
            if (!isConnected) {
                OfflineView(message: "Offline mode")
            } else {
                topBarView
                Group {
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
                Spacer()
            }
        }
        .padding()
        .onAppear {
            checkInternetConnection()
        }
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
    
    var topBarView: some View {
        return HStack {
            Text("Smart Budget")
                .font(.title)
                .padding()
            Spacer()
            if case .success(let data) = categoriesStore.mainCategoryState {
                Group {
                    Text("\(String(format: "%.f", categoriesStore.total_expenses)) / \(String(format: "%.f", data.max_expense!)) €")
                        .padding(5)
                }
                .background(Color.purple.opacity(0.3))
                .cornerRadius(5)
            }
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
}
