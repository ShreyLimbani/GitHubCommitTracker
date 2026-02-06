//
//  MenuBarViewModel.swift
//  GitHubCommitTracker
//
//  Main state management for the MenuBar app
//

import Foundation
import SwiftUI
import WidgetKit

/// Settings display mode
enum SettingsMode {
    case onboarding     // First-time setup (add first account)
    case fullSettings   // Full settings view (manage accounts, appearance, etc.)
}

@MainActor
@Observable
class MenuBarViewModel {

    // MARK: - Published State
    var commitHistory: CommitHistory?
    var streakStats: StreakStatistics = .empty
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedMonth: Date = Date()
    var appSettings: AppSettings = AppSettings()
    var showSettings: Bool = false
    var settingsMode: SettingsMode = .onboarding
    var lastUpdateTime: Date?

    // MARK: - Services
    private let apiService = GitHubAPIService()
    private let cacheManager = CacheManager()

    // MARK: - Computed Properties

    var hasToken: Bool {
        guard let activeAccountId = appSettings.activeAccountId else { return false }
        return KeychainService.hasToken(for: activeAccountId)
    }

    var needsOnboarding: Bool {
        !appSettings.hasCompletedOnboarding || !appSettings.hasAccounts
    }

    var lastUpdateText: String {
        guard let lastUpdate = lastUpdateTime else {
            return "Never updated"
        }
        return "Last updated: \(DateUtilities.relativeTimeString(from: lastUpdate))"
    }

    var currentMonthDays: [Date] {
        DateUtilities.datesInMonth(for: selectedMonth)
    }

    // MARK: - Initialization

    init() {
        Task {
            await loadInitialData()
        }
    }

    // MARK: - Data Loading

    /// Load initial data on app launch
    func loadInitialData() async {
        // Load settings (with automatic migration from legacy)
        do {
            appSettings = try cacheManager.loadAppSettings()
        } catch {
            print("Failed to load app settings: \(error)")
            appSettings = AppSettings()
        }

        // Apply saved appearance
        AppearanceManager.shared.loadFromSettings(appSettings.appearanceMode)

        // Check if onboarding is needed
        if needsOnboarding {
            settingsMode = .onboarding
            showSettings = true
            return
        }

        // Load cached data immediately for instant UI
        loadCachedData()

        // Then fetch fresh data in background
        await refreshData()
    }

    /// Load commit history from cache
    func loadCachedData() {
        guard let accountId = appSettings.activeAccountId else { return }

        do {
            let cachedHistory = try cacheManager.loadCommitHistory(for: accountId)
            commitHistory = cachedHistory
            streakStats = StreakCalculator.calculateStatistics(from: cachedHistory)
            lastUpdateTime = cachedHistory.lastFetched
        } catch {
            // No cached data or corrupted, will fetch fresh
            print("Failed to load cache: \(error)")
        }
    }

    /// Refresh data from GitHub API
    func refreshData() async {
        guard let activeAccount = appSettings.activeAccount,
              let token = try? KeychainService.loadToken(for: activeAccount.id) else {
            errorMessage = "Missing credentials"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Fetch contributions from GitHub
            let commitDays = try await apiService.fetchRecentContributions(
                username: activeAccount.username,
                token: token
            )

            // Create new history
            let newHistory = CommitHistory(
                username: activeAccount.username,
                days: commitDays,
                lastFetched: Date()
            )

            // Update state
            commitHistory = newHistory
            streakStats = StreakCalculator.calculateStatistics(from: newHistory)
            lastUpdateTime = Date()

            // Cache the data for this account
            try? cacheManager.saveCommitHistory(newHistory, for: activeAccount.id)

            // Reload widget timelines to reflect new data
            WidgetCenter.shared.reloadAllTimelines()

        } catch let error as GitHubAPIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to fetch data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Month Navigation

    func navigateMonth(offset: Int) {
        selectedMonth = DateUtilities.addMonths(offset, to: selectedMonth)
    }

    func goToCurrentMonth() {
        selectedMonth = Date()
    }

    // MARK: - Commit Data Queries

    func commitCount(for date: Date) -> Int {
        guard let history = commitHistory else { return 0 }
        return history.commits(for: date)?.commitCount ?? 0
    }

    func hasCommits(for date: Date) -> Bool {
        commitCount(for: date) > 0
    }

    // MARK: - Settings Management

    func saveToken(_ token: String) async {
        do {
            // Validate token first
            let username = try await apiService.validateToken(token)

            // Create new account
            let newAccount = GitHubAccount(
                username: username,
                displayName: nil,
                dateAdded: Date(),
                isActive: true
            )

            // Save token to per-account keychain
            try KeychainService.saveToken(token, for: username)

            // Update app settings
            appSettings.accounts = [newAccount]
            appSettings.activeAccountId = username
            appSettings.hasCompletedOnboarding = true
            try? cacheManager.saveAppSettings(appSettings)

            // Close settings and fetch data
            showSettings = false
            await refreshData()

        } catch let error as GitHubAPIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to save token: \(error.localizedDescription)"
        }
    }

    func logout() async {
        // Delete all account tokens
        for account in appSettings.accounts {
            try? KeychainService.deleteToken(for: account.id)
        }

        // Clear all data
        try? cacheManager.clearAllData()

        // Reset state
        commitHistory = nil
        streakStats = .empty
        appSettings = AppSettings()
        settingsMode = .onboarding
        showSettings = true
    }

    // MARK: - Account Management

    /// Switch to a different account
    func switchAccount(to accountId: String) async {
        guard appSettings.accounts.first(where: { $0.id == accountId }) != nil else {
            errorMessage = "Account not found"
            return
        }

        // Update active account
        appSettings.activeAccountId = accountId
        try? cacheManager.saveAppSettings(appSettings)

        // Clear current data
        commitHistory = nil
        streakStats = .empty
        lastUpdateTime = nil

        // Load cached data for new account
        loadCachedData()

        // Refresh data from API
        await refreshData()

        // Reload widget timelines to show new account data
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Add a new account
    func addAccount(_ token: String) async throws -> GitHubAccount {
        // Validate token first
        let username = try await apiService.validateToken(token)

        // Check if account already exists
        if appSettings.accounts.contains(where: { $0.username == username }) {
            throw GitHubAPIError.duplicateAccount
        }

        // Create new account
        let newAccount = GitHubAccount(
            username: username,
            displayName: nil,
            dateAdded: Date(),
            isActive: false
        )

        // Save token to per-account keychain
        try KeychainService.saveToken(token, for: username)

        // Add account to settings
        appSettings.accounts.append(newAccount)
        try? cacheManager.saveAppSettings(appSettings)

        return newAccount
    }

    /// Remove an account
    func removeAccount(_ accountId: String) async {
        // Don't allow removing the last account
        guard appSettings.accounts.count > 1 else {
            await logout()
            return
        }

        // Remove account from list
        appSettings.accounts.removeAll { $0.id == accountId }

        // Delete token from keychain
        try? KeychainService.deleteToken(for: accountId)

        // Remove account data from cache
        try? cacheManager.removeAccountData(accountId)

        // If we removed the active account, switch to the first remaining account
        if appSettings.activeAccountId == accountId {
            if let firstAccount = appSettings.accounts.first {
                appSettings.activeAccountId = firstAccount.id
                await switchAccount(to: firstAccount.id)
            }
        } else {
            // Just save settings
            try? cacheManager.saveAppSettings(appSettings)
        }
    }

    /// Logout current account only
    func logoutAccount(_ accountId: String) async {
        // If this is the only account, perform full logout
        if appSettings.accounts.count == 1 {
            await logout()
            return
        }

        // Otherwise, just remove this account
        await removeAccount(accountId)
    }

    // MARK: - Appearance Management

    /// Set app appearance mode
    func setAppearance(_ mode: AppearanceMode) {
        appSettings.appearanceMode = mode
        try? cacheManager.saveAppSettings(appSettings)
        AppearanceManager.shared.setAppearance(mode)
    }

    // MARK: - Settings Navigation

    /// Open settings with specified mode
    func openSettings(mode: SettingsMode) {
        settingsMode = mode
        showSettings = true
    }

    /// Close settings
    func closeSettings() {
        showSettings = false
    }
}
