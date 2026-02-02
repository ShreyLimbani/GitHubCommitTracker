//
//  SettingsView.swift
//  GitHubCommitTracker
//
//  Onboarding and settings UI for token setup
//

import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    let onComplete: (String) async -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)

                Text(Constants.Text.appName)
                    .font(.system(size: 20, weight: .semibold))
            }
            .padding(.top, 20)

            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("Setup GitHub Token")
                    .font(.system(size: 16, weight: .semibold))

                Text(Constants.Text.tokenInstructions)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)

            // Action buttons
            HStack(spacing: 12) {
                Button("Create Token") {
                    viewModel.openGitHubTokenPage()
                }
                .buttonStyle(.borderedProminent)

                Button("Help") {
                    viewModel.openTokenHelpPage()
                }
                .buttonStyle(.bordered)
            }

            Divider()

            // Token input
            VStack(alignment: .leading, spacing: 8) {
                Text("Paste Your Token")
                    .font(.system(size: 13, weight: .medium))

                SecureField(Constants.Text.tokenPlaceholder, text: $viewModel.tokenInput)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12, design: .monospaced))
                    .disabled(viewModel.isValidating)

                // Validation feedback
                if let error = viewModel.validationError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                }

                if viewModel.validationSuccess {
                    Label("Token validated successfully!", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)

            // Validate button
            Button(action: validateAndComplete) {
                HStack {
                    if viewModel.isValidating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 16, height: 16)
                    } else {
                        Text("Connect")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canValidate)
            .padding(.horizontal)

            Spacer()
        }
        .frame(width: Constants.UI.popoverWidth, height: Constants.UI.popoverHeight)
        .background(Constants.Colors.background)
    }

    private func validateAndComplete() {
        Task {
            do {
                _ = try await viewModel.validateToken()
                await onComplete(viewModel.tokenInput)
            } catch {
                // Error is already set in viewModel
            }
        }
    }
}

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(),
        onComplete: { _ in }
    )
}
