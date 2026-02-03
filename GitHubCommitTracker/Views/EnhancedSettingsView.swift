//
//  EnhancedSettingsView.swift
//  GitHubCommitTracker
//
//  Main settings view with account management and appearance
//

import SwiftUI

struct EnhancedSettingsView: View {
    @State private var viewModel: EnhancedSettingsViewModel

    init(mainViewModel: MenuBarViewModel) {
        _viewModel = State(initialValue: EnhancedSettingsViewModel(mainViewModel: mainViewModel))
    }

    var body: some View {
        Group {
            if viewModel.isAddingAccount {
                // Show add account view
                AddAccountView(viewModel: viewModel)
            } else {
                // Show main settings
                mainSettingsView
            }
        }
        .alert("Remove Account", isPresented: $viewModel.showRemoveConfirmation) {
            Button("Cancel", role: .cancel) {
                viewModel.cancelRemoveAccount()
            }
            Button("Remove", role: .destructive) {
                Task {
                    await viewModel.confirmRemoveAccount()
                }
            }
        } message: {
            if let account = viewModel.accountToRemove {
                Text("Are you sure you want to remove @\(account.username)?")
            }
        }
    }

    private var mainSettingsView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    viewModel.closeSettings()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Settings")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                // Invisible spacer for symmetry
                // Color.clear.frame(width: 20)
            }
            .padding(.horizontal, Constants.UI.padding)
            .padding(.vertical, 10)

            Divider()

            ScrollView {
                VStack(spacing: 24) {
                    // Accounts section
                    AccountsSection(viewModel: viewModel)

                    Divider()

                    // Appearance section
                    AppearanceSection(viewModel: viewModel)

                    Divider()

                    // About section
                    AboutSection(viewModel: viewModel)
                }
                .padding(Constants.UI.padding)
            }

            Spacer()
        }
        .frame(width: Constants.UI.popoverWidth)
        .background(Constants.Colors.background)
    }
}

#Preview {
    EnhancedSettingsView(mainViewModel: MenuBarViewModel())
}
