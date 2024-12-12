//
//  SettingsView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI

struct Constants {
    static let inset: CGFloat = 8
    static let spacing: CGFloat = 20
    static let sectionSpacing: CGFloat = 10
    static let cardInset: CGFloat = 18
    static let cornerRadius: CGFloat = 10
    
    static let secondaryOpacity: CGFloat = 0.1
    
    struct FontSize {
        static let largest: CGFloat = 34
        static let normal: CGFloat = 18
    }
}

struct SettingsView: View {
    @ObservedObject var profileViewModel =  ProfileViewModel()
    @Environment(Settings.self) private var settings: Settings
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.title)
            switch(profileViewModel.profileState) {
            case .success(let user):
                ScrollView {
                    VStack(alignment: .leading, spacing: Constants.spacing) {
                        
                        HStack{
                            Spacer()
                            Text(user.firstname.first?.uppercased() ?? "?")
                                .font(.system(size: 34, weight: .bold))
                                .padding(20)
                                .foregroundColor(.white)
                                .background(.purple)
                                .clipShape(.circle)
                            Spacer()
                        }
                        
                        accountDetails(user: user)
                        AppSettings(settings: settings)
                    }
                }
            case .failure(let error):
                HStack(alignment: .center) {
                    Image(systemName: "exclamationmark.triangle")
                    Text(error.localizedDescription)
                        .font(.headline)
                        .padding()
                }
            default:
                VStack(alignment: .center) {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            Button {
                Auth.shared.logout()
            } label: {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.danger)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.cornerRadius)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func accountDetails(user: User) -> some View {
        Section("Account settings") {
            VStack(spacing: Constants.sectionSpacing) {
                Button{
                    Task {
                        await ChangeNamePopup(profileViewModel: profileViewModel).present()
                    }
                } label: {
                    Text("Name")
                        .font(.system(size: Constants.FontSize.normal ,weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(user.firstname + " " + user.lastname)
                        .font(.system(size: Constants.FontSize.normal))
                        .foregroundColor(.secondary)
                }
                .padding(Constants.cardInset)
                .background(.secondary.opacity(Constants.secondaryOpacity))
                .cornerRadius(Constants.cornerRadius)
                Button{
                    Task { await ChangeEmailPopup(profileViewModel: profileViewModel).present() }
                } label: {
                    Text("Email")
                        .font(.system(size: Constants.FontSize.normal ,weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(user.email)
                        .font(.system(size: Constants.FontSize.normal))
                        .tint(.secondary)
                        .foregroundColor(.secondary)
                }
                .padding(Constants.cardInset)
                .background(.secondary.opacity(Constants.secondaryOpacity))
                .cornerRadius(Constants.cornerRadius)
                
                Button {
                    Task { await ChangePasswordPopup(profileViewModel: profileViewModel).present() }
                } label: {
                    Text("Change password")
                        .font(.system(size: Constants.FontSize.normal ,weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(Constants.cardInset)
                .background(.secondary.opacity(Constants.secondaryOpacity))
                .cornerRadius(Constants.cornerRadius)
            }
        }
    }
}

struct AppSettings: View {
    @Bindable var settings: Settings
    
    var body: some View {
        Section("App settings") {
            Button {
                Task { await ChangeCurrencyPopup(settings: settings, selectedType: settings.currency).present() }
            } label: {
                Text("Currency")
                    .font(.system(size: Constants.FontSize.normal ,weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text(settings.currency.rawValue)
                    .font(.system(size: Constants.FontSize.normal))
                    .foregroundColor(.secondary)
            }
            .padding(Constants.cardInset)
            .background(.secondary.opacity(Constants.secondaryOpacity))
            .cornerRadius(Constants.cornerRadius)
            HStack {
                Text("Dark mode")
                    .font(.system(size: Constants.FontSize.normal ,weight: .bold))
                Spacer()
                Toggle(isOn: $settings.darKMode, label: {
                    Text("Dark mode")
                        .font(.system(size: Constants.FontSize.normal))
                        .foregroundColor(.secondary)
                })
                .toggleStyle(.switch)
                .labelsHidden()
            }
            .padding(Constants.cardInset)
            .background(.secondary.opacity(Constants.secondaryOpacity))
            .cornerRadius(Constants.cornerRadius)
        }
    }
}

#Preview {
    SettingsView()
        .fontDesign(.rounded)
        .background(Color.background)
}
