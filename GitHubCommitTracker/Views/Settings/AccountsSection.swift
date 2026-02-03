//
//  AccountsSection.swift
//  GitHubCommitTracker
//
//  Displays and manages GitHub accounts
//

import SwiftUI

struct AccountsSection: View {
    let viewModel: EnhancedSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text("Accounts")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.7))

            // Account list
            VStack(spacing: 8) {
                ForEach(viewModel.accounts) { account in
                    AccountRow(
                        account: account,
                        isActive: account.id == viewModel.activeAccountId,
                        onTap: {
                            Task {
                                await viewModel.switchAccount(to: account)
                            }
                        },
                        onRemove: {
                            viewModel.requestRemoveAccount(account)
                        }
                    )
                }

                // Add account button
                Button(action: {
                    viewModel.startAddingAccount()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.accentColor)

                        Text("Add Account")
                            .font(.system(size: 13))
                            .foregroundColor(.accentColor)

                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct AccountRow: View {
    let account: GitHubAccount
    let isActive: Bool
    let onTap: () -> Void
    let onRemove: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Active indicator
            Circle()
                .fill(isActive ? Color.green : Color.clear)
                .frame(width: 8, height: 8)

            // Account info
            VStack(alignment: .leading, spacing: 2) {
                Text("@\(account.username)")
                    .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                    .foregroundColor(.primary)

                if let displayName = account.displayName {
                    Text(displayName)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Remove button (shown on hover)
            if isHovered && !isActive {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isActive ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            if !isActive {
                onTap()
            }
        }
    }
}

#Preview {
    AccountsSection(
        viewModel: EnhancedSettingsViewModel(
            mainViewModel: MenuBarViewModel()
        )
    )
    .frame(width: Constants.UI.popoverWidth)
    .padding()
}
