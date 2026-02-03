//
//  EnhancedSettingsViewModel.swift
//  GitHubCommitTracker
//
//  ViewModel for enhanced settings with account management and appearance
//

import Foundation
import SwiftUI

@MainActor
@Observable
class EnhancedSettingsViewModel {

    // MARK: - State
    var isAddingAccount: Bool = false
    var tokenInput: String = ""
    var isValidatingToken: Bool = false
    var validationError: String?
    var accountToRemove: GitHubAccount?
    var showRemoveConfirmation: Bool = false

    // MARK: - Services
    private let mainViewModel: MenuBarViewModel

    // MARK: - Initialization

    init(mainViewModel: MenuBarViewModel) {
        self.mainViewModel = mainViewModel
    }

    // MARK: - Computed Properties

    var accounts: [GitHubAccount] {
        mainViewModel.appSettings.accounts
    }

    var activeAccountId: String? {
        mainViewModel.appSettings.activeAccountId
    }

    var currentAppearance: AppearanceMode {
        mainViewModel.appSettings.appearanceMode
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1"
    }

    // MARK: - Account Management

    /// Start adding a new account
    func startAddingAccount() {
        tokenInput = ""
        validationError = nil
        isAddingAccount = true
    }

    /// Cancel adding account
    func cancelAddingAccount() {
        isAddingAccount = false
        tokenInput = ""
        validationError = nil
    }

    /// Add new account with token
    func addAccount() async {
        guard !tokenInput.isEmpty else {
            validationError = "Please enter a token"
            return
        }

        isValidatingToken = true
        validationError = nil

        do {
            let newAccount = try await mainViewModel.addAccount(tokenInput)

            // Successfully added account
            isAddingAccount = false
            tokenInput = ""

            // Optionally switch to the new account
            // await mainViewModel.switchAccount(to: newAccount.id)

        } catch let error as GitHubAPIError {
            validationError = error.localizedDescription
        } catch {
            validationError = "Failed to add account: \(error.localizedDescription)"
        }

        isValidatingToken = false
    }

    /// Switch to a different account
    func switchAccount(to account: GitHubAccount) async {
        guard account.id != activeAccountId else { return }
        await mainViewModel.switchAccount(to: account.id)
    }

    /// Request account removal confirmation
    func requestRemoveAccount(_ account: GitHubAccount) {
        accountToRemove = account
        showRemoveConfirmation = true
    }

    /// Cancel account removal
    func cancelRemoveAccount() {
        accountToRemove = nil
        showRemoveConfirmation = false
    }

    /// Confirm and remove account
    func confirmRemoveAccount() async {
        guard let account = accountToRemove else { return }

        showRemoveConfirmation = false
        await mainViewModel.removeAccount(account.id)
        accountToRemove = nil
    }

    // MARK: - Appearance Management

    /// Set appearance mode
    func setAppearance(_ mode: AppearanceMode) {
        mainViewModel.setAppearance(mode)
    }

    // MARK: - Navigation

    /// Close settings
    func closeSettings() {
        mainViewModel.closeSettings()
    }

    /// Logout current account
    func logoutCurrentAccount() async {
        guard let accountId = activeAccountId else { return }
        await mainViewModel.logoutAccount(accountId)
    }

    /// Remove all data
    func removeAllData() async {
        await mainViewModel.logout()
    }
}
