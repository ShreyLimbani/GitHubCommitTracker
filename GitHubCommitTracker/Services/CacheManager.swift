//
//  CacheManager.swift
//  GitHubCommitTracker
//
//  Manages local caching of commit data
//

@preconcurrency import Foundation

enum CacheError: Error {
    case invalidDirectory
    case failedToWrite
    case failedToRead
    case corruptedData
}

final class CacheManager {
    private let cacheFileName = "commit_history.json" // Legacy
    private let settingsFileName = "user_settings.json" // Legacy
    private let appSettingsFileName = "app_settings.json"
    private let accountsDirectoryName = "accounts"
    private let cacheMaxAge: TimeInterval = 3600 // 1 hour

    /// Get the cache directory URL
    private var cacheDirectory: URL? {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        let bundleID = Bundle.main.bundleIdentifier ?? "com.github-commit-tracker"
        let directory = appSupport.appendingPathComponent(bundleID)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }

    // MARK: - Per-Account Methods

    /// Get the accounts directory URL
    private func accountsDirectory() throws -> URL {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        let accountsDir = directory.appendingPathComponent(accountsDirectoryName)
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: accountsDir.path) {
            try fileManager.createDirectory(at: accountsDir, withIntermediateDirectories: true)
        }

        return accountsDir
    }

    /// Get directory for a specific account
    private func accountDirectory(for accountId: String) throws -> URL {
        let accountsDir = try accountsDirectory()
        let accountDir = accountsDir.appendingPathComponent(accountId)
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: accountDir.path) {
            try fileManager.createDirectory(at: accountDir, withIntermediateDirectories: true)
        }

        return accountDir
    }

    /// Save app settings
    func saveAppSettings(_ settings: AppSettings) throws {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        let fileURL = directory.appendingPathComponent(appSettingsFileName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(settings)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw CacheError.failedToWrite
        }
    }

    /// Load app settings with automatic migration
    func loadAppSettings() throws -> AppSettings {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        let fileURL = directory.appendingPathComponent(appSettingsFileName)

        // If app settings exist, load them
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            do {
                let data = try Data(contentsOf: fileURL)
                let settings = try decoder.decode(AppSettings.self, from: data)
                return settings
            } catch {
                throw CacheError.corruptedData
            }
        }

        // Otherwise, attempt migration from legacy settings
        return try migrateLegacySettings()
    }

    /// Save commit history for a specific account
    func saveCommitHistory(_ history: CommitHistory, for accountId: String) throws {
        let accountDir = try accountDirectory(for: accountId)
        let fileURL = accountDir.appendingPathComponent(cacheFileName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(history)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw CacheError.failedToWrite
        }
    }

    /// Load commit history for a specific account
    func loadCommitHistory(for accountId: String) throws -> CommitHistory {
        let accountDir = try accountDirectory(for: accountId)
        let fileURL = accountDir.appendingPathComponent(cacheFileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw CacheError.failedToRead
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: fileURL)
            let history = try decoder.decode(CommitHistory.self, from: data)
            return history
        } catch {
            throw CacheError.corruptedData
        }
    }

    /// Remove all data for a specific account
    func removeAccountData(_ accountId: String) throws {
        let accountsDir = try accountsDirectory()
        let accountDir = accountsDir.appendingPathComponent(accountId)

        if FileManager.default.fileExists(atPath: accountDir.path) {
            try FileManager.default.removeItem(at: accountDir)
        }
    }

    // MARK: - Migration

    /// Migrate legacy settings to new AppSettings structure
    func migrateLegacySettings() throws -> AppSettings {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        // Try to load legacy user settings
        let legacySettingsURL = directory.appendingPathComponent(settingsFileName)
        let legacyHistoryURL = directory.appendingPathComponent(cacheFileName)

        var appSettings = AppSettings()

        // Check if legacy settings exist
        if FileManager.default.fileExists(atPath: legacySettingsURL.path) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            do {
                let data = try Data(contentsOf: legacySettingsURL)
                let legacySettings = try decoder.decode(UserSettings.self, from: data)

                // If we have a username, create an account
                if let username = legacySettings.username {
                    let account = GitHubAccount(
                        username: username,
                        displayName: nil,
                        dateAdded: legacySettings.lastRefreshDate ?? Date(),
                        isActive: true
                    )
                    appSettings.accounts = [account]
                    appSettings.activeAccountId = username
                    appSettings.hasCompletedOnboarding = legacySettings.hasCompletedOnboarding
                    appSettings.refreshInterval = legacySettings.refreshInterval

                    // Try to migrate commit history for this account
                    if FileManager.default.fileExists(atPath: legacyHistoryURL.path) {
                        do {
                            let historyData = try Data(contentsOf: legacyHistoryURL)
                            let history = try decoder.decode(CommitHistory.self, from: historyData)

                            // Save to new per-account location
                            try saveCommitHistory(history, for: username)

                            // Delete legacy history file
                            try? FileManager.default.removeItem(at: legacyHistoryURL)
                        } catch {
                            print("Failed to migrate commit history: \(error)")
                        }
                    }

                    // Try to migrate token from legacy keychain
                    if KeychainService.hasToken() {
                        if let legacyToken = try? KeychainService.loadToken() {
                            // Save to per-account keychain
                            try? KeychainService.saveToken(legacyToken, for: username)
                            // Keep legacy token for now (don't delete for safety)
                        }
                    }
                }

                // Save the new app settings
                try saveAppSettings(appSettings)

                // Delete legacy settings file
                try? FileManager.default.removeItem(at: legacySettingsURL)

                return appSettings
            } catch {
                print("Failed to load legacy settings: \(error)")
            }
        }

        // Return default settings if no migration needed
        return appSettings
    }

    /// Clear all data including per-account data
    func clearAllData() throws {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        // Remove accounts directory
        let accountsDir = directory.appendingPathComponent(accountsDirectoryName)
        if FileManager.default.fileExists(atPath: accountsDir.path) {
            try FileManager.default.removeItem(at: accountsDir)
        }

        // Remove app settings
        let appSettingsURL = directory.appendingPathComponent(appSettingsFileName)
        if FileManager.default.fileExists(atPath: appSettingsURL.path) {
            try FileManager.default.removeItem(at: appSettingsURL)
        }

        // Remove legacy files if they exist
        let legacyHistoryURL = directory.appendingPathComponent(cacheFileName)
        if FileManager.default.fileExists(atPath: legacyHistoryURL.path) {
            try? FileManager.default.removeItem(at: legacyHistoryURL)
        }

        let legacySettingsURL = directory.appendingPathComponent(settingsFileName)
        if FileManager.default.fileExists(atPath: legacySettingsURL.path) {
            try? FileManager.default.removeItem(at: legacySettingsURL)
        }
    }
}
