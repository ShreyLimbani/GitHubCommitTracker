//
//  MenuBarViewModel.swift
//  GitHubCommitTracker
//
//  Main state management for the MenuBar app
//

import Foundation
import SwiftUI

@MainActor
@Observable
class MenuBarViewModel {

    // MARK: - Published State
    var commitHistory: CommitHistory?
    var streakStats: StreakStatistics = .empty
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedMonth: Date = Date()
    var settings: UserSettings = UserSettings()
    var showSettings: Bool = false
    var lastUpdateTime: Date?

    // MARK: - Services
    private let apiService = GitHubAPIService()
    private let cacheManager = CacheManager()

    // MARK: - Computed Properties

    var hasToken: Bool {
        KeychainService.hasToken()
    }

    var needsOnboarding: Bool {
        !hasToken || settings.username == nil
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
        // Load settings
        if let loadedSettings = try? await cacheManager.loadSettings() {
            settings = loadedSettings
        }

        // Check if onboarding is needed
        if needsOnboarding {
            showSettings = true
            return
        }

        // Load cached data immediately for instant UI
        await loadCachedData()

        // Then fetch fresh data in background
        await refreshData()
    }

    /// Load commit history from cache
    func loadCachedData() async {
        do {
            let cachedHistory = try await cacheManager.loadCommitHistory()
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
        guard let username = settings.username,
              let token = try? KeychainService.loadToken() else {
            errorMessage = "Missing credentials"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Fetch contributions from GitHub
            let commitDays = try await apiService.fetchRecentContributions(
                username: username,
                token: token
            )

            // Create new history
            let newHistory = CommitHistory(
                username: username,
                days: commitDays,
                lastFetched: Date()
            )

            // Update state
            commitHistory = newHistory
            streakStats = StreakCalculator.calculateStatistics(from: newHistory)
            lastUpdateTime = Date()

            // Cache the data
            try? await cacheManager.saveCommitHistory(newHistory)

            // Update settings
            settings.lastRefreshDate = Date()
            try? await cacheManager.saveSettings(settings)

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

            // Save to keychain
            try KeychainService.saveToken(token)

            // Update settings
            settings.username = username
            settings.hasCompletedOnboarding = true
            try? await cacheManager.saveSettings(settings)

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
        try? KeychainService.deleteToken()
        try? await cacheManager.clearAllCache()

        commitHistory = nil
        streakStats = .empty
        settings = UserSettings()
        showSettings = true
    }
}
