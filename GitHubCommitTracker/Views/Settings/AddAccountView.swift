//
//  AddAccountView.swift
//  GitHubCommitTracker
//
//  View for adding a new GitHub account
//

import SwiftUI

struct AddAccountView: View {
    let viewModel: EnhancedSettingsViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    viewModel.cancelAddingAccount()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Add Account")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                // Spacer for alignment
                Color.clear
                    .frame(width: 20)
            }

            Divider()

            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("GitHub Personal Access Token")
                    .font(.system(size: 14, weight: .semibold))

                Text("To track your commit activity, you need to provide a GitHub Personal Access Token with 'read:user' permission.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Link to create token
                Link(destination: URL(string: "https://github.com/settings/tokens/new")!) {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                            .font(.system(size: 11))

                        Text("Create a new token on GitHub")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.accentColor)
                }
            }

            // Token input
            VStack(alignment: .leading, spacing: 8) {
                Text("Token")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                SecureField("ghp_xxxxxxxxxxxxxxxxxxxx", text: Binding(
                    get: { viewModel.tokenInput },
                    set: { viewModel.tokenInput = $0 }
                ))
                .textFieldStyle(.plain)
                .font(.system(size: 13, design: .monospaced))
                .padding(10)
                .background(Constants.Colors.secondaryBackground)
                .cornerRadius(6)
                .disabled(viewModel.isValidatingToken)
            }

            // Error message
            if let error = viewModel.validationError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)

                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
                .padding(10)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
            }

            Spacer()

            // Add button
            Button(action: {
                Task {
                    await viewModel.addAccount()
                }
            }) {
                HStack {
                    if viewModel.isValidatingToken {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 16, height: 16)
                    }

                    Text(viewModel.isValidatingToken ? "Validating..." : "Add Account")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(viewModel.tokenInput.isEmpty ? Color.gray.opacity(0.3) : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.tokenInput.isEmpty || viewModel.isValidatingToken)
        }
        .padding(Constants.UI.padding)
        .frame(width: Constants.UI.popoverWidth)
        .background(Constants.Colors.background)
    }
}

#Preview {
    AddAccountView(
        viewModel: EnhancedSettingsViewModel(
            mainViewModel: MenuBarViewModel()
        )
    )
}
