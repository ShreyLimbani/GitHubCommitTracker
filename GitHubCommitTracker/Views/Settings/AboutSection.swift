//
//  AboutSection.swift
//  GitHubCommitTracker
//
//  App information and logout options
//

import SwiftUI

struct AboutSection: View {
    let viewModel: EnhancedSettingsViewModel
    @State private var showLogoutConfirmation = false
    @State private var showRemoveAllDataConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text("About")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.7))

            // App version
            HStack {
                Text("Version")
                    .font(.system(size: 13))
                    .foregroundColor(.primary)

                Spacer()

                Text(viewModel.appVersion)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Constants.Colors.secondaryBackground)
            .cornerRadius(6)

            Divider()
                .padding(.vertical, 4)

            // Logout current account button
            Button(action: {
                showLogoutConfirmation = true
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 13))
                        .foregroundColor(.orange)

                    Text("Logout Current Account")
                        .font(.system(size: 13))
                        .foregroundColor(.orange)

                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .confirmationDialog(
                "Logout Account",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Logout", role: .destructive) {
                    Task {
                        await viewModel.logoutCurrentAccount()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to logout from this account?")
            }

            // Remove all data button
            Button(action: {
                showRemoveAllDataConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.red)

                    Text("Remove All Data")
                        .font(.system(size: 13))
                        .foregroundColor(.red)

                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .confirmationDialog(
                "Remove All Data",
                isPresented: $showRemoveAllDataConfirmation,
                titleVisibility: .visible
            ) {
                Button("Remove All Data", role: .destructive) {
                    Task {
                        await viewModel.removeAllData()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all accounts and cached data. This action cannot be undone.")
            }
        }
    }
}

#Preview {
    AboutSection(
        viewModel: EnhancedSettingsViewModel(
            mainViewModel: MenuBarViewModel()
        )
    )
    .frame(width: Constants.UI.popoverWidth)
    .padding()
}
