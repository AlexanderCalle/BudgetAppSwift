//
//  SettingsView.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 24/11/2024.
//

import SwiftUI

struct ContentStyle {
    static let inset: CGFloat = 8
    static let spacing: CGFloat = 20
    static let sectionSpacing: CGFloat = 10
    static let cardInset: CGFloat = 18
    static let cornerRadius: CGFloat = 10
    static let profileImagePadding: CGFloat = 20
    static let logoutPaddingTop: CGFloat = 20
    
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
        VStack(alignment: .leading, spacing: ContentStyle.spacing) {
            Text("Settings")
                .font(.title)
            ScrollView {
                VStack(alignment: .leading, spacing: ContentStyle.spacing) {
                    if profileViewModel.profile != nil {
                        VStack(alignment: .leading, spacing: ContentStyle.spacing) {
                            profileImage
                            accountDetails(user: profileViewModel.profile!)
                            AppSettings(settings: settings)
                        }
                    } else {
                        HStack(alignment: .center) {
                            Image(systemName: "exclamationmark.triangle")
                            Text("No user found")
                                .font(.headline)
                                .padding()
                        }
                    }
                    
                    LargeButton("Logout", theme: .warning) {
                        Auth.shared.logout()
                    }
                    .padding(.top, ContentStyle.logoutPaddingTop)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var profileImage: some View {
        HStack{
            Spacer()
            Text(profileViewModel.profile?.firstname.first?.uppercased() ?? "?")
                .font(.system(size: ContentStyle.FontSize.largest, weight: .bold))
                .padding(ContentStyle.profileImagePadding)
                .foregroundColor(.white)
                .background(.purple)
                .clipShape(.circle)
            Spacer()
        }
    }
    
    private func accountDetails(user: User) -> some View {
        Section("Account settings") {
            VStack(spacing: ContentStyle.sectionSpacing) {
                SettingDetailButton("Name", text: user.firstname + " " + user.lastname) {
                    Task { await ChangeNamePopup(profileViewModel: profileViewModel).present() }
                }
                
                SettingDetailButton("Email", text: user.email) {
                    Task { await ChangeEmailPopup(profileViewModel: profileViewModel).present() }
                }
                
                SettingDetailButton("Change password", showIcon: true) {
                    Task { await ChangePasswordPopup(profileViewModel: profileViewModel).present() }
                }
            }
        }
    }
}

struct AppSettings: View {
    @Bindable var settings: Settings
    
    var body: some View {
        Section("App settings") {
            VStack(spacing: ContentStyle.sectionSpacing) {
                SettingDetailButton("Currency", text: settings.currency.rawValue) {
                    Task { await ChangeCurrencyPopup(settings: settings, selectedType: settings.currency).present() }
                }
                
                HStack {
                    Text("Dark mode")
                        .font(.system(size: ContentStyle.FontSize.normal ,weight: .bold))
                    Spacer()
                    Toggle(isOn: $settings.darKMode, label: {
                        Text("Dark mode")
                            .font(.system(size: ContentStyle.FontSize.normal))
                            .foregroundColor(.secondary)
                    })
                    .toggleStyle(.switch)
                    .labelsHidden()
                }
                .padding(ContentStyle.cardInset)
                .background(.secondary.opacity(ContentStyle.secondaryOpacity))
                .cornerRadius(ContentStyle.cornerRadius)
            }
        }
    }
}

struct SettingDetailButton: View {
    private let label: String
    private let action: () -> Void
    private let text: String
    private var showIcon: Bool = false
    
    init(_ label: String, text: String = "", showIcon: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.action = action
        self.text = text
        self.showIcon = showIcon
    }
    
    var body: some View {
        Button{
           action()
        } label: {
            Text(label)
                .font(.system(size: ContentStyle.FontSize.normal ,weight: .bold))
                .foregroundColor(.primary)
            Spacer()
            if(showIcon) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            } else {
                Text(text)
                    .font(.system(size: ContentStyle.FontSize.normal))
                    .tint(.secondary)
                    .foregroundColor(.secondary)
            }
        }
        .padding(ContentStyle.cardInset)
        .background(.secondary.opacity(ContentStyle.secondaryOpacity))
        .cornerRadius(ContentStyle.cornerRadius)
    }
}

#Preview {
    SettingsView()
        .fontDesign(.rounded)
        .background(Color.background)
}
