//
//  CacheManager.swift
//  GitHubCommitTracker
//
//  Manages local caching of commit data
//

import Foundation

enum CacheError: Error {
    case invalidDirectory
    case failedToWrite
    case failedToRead
    case corruptedData
}

actor CacheManager {
    private let fileManager = FileManager.default
    private let cacheFileName = "commit_history.json"
    private let settingsFileName = "user_settings.json"
    private let cacheMaxAge: TimeInterval = 3600 // 1 hour

    /// Get the cache directory URL
    private var cacheDirectory: URL? {
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

    // MARK: - Commit History Cache

    /// Save commit history to cache
    func saveCommitHistory(_ history: CommitHistory) throws {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        let fileURL = directory.appendingPathComponent(cacheFileName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(history)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw CacheError.failedToWrite
        }
    }

    /// Load commit history from cache
    func loadCommitHistory() throws -> CommitHistory {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        let fileURL = directory.appendingPathComponent(cacheFileName)

        guard fileManager.fileExists(atPath: fileURL.path) else {
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

    /// Check if cached data exists
    func hasCachedData() -> Bool {
        guard let directory = cacheDirectory else { return false }
        let fileURL = directory.appendingPathComponent(cacheFileName)
        return fileManager.fileExists(atPath: fileURL.path)
    }

    /// Check if cached data is still valid (not expired)
    func isCacheValid() -> Bool {
        guard let directory = cacheDirectory else { return false }
        let fileURL = directory.appendingPathComponent(cacheFileName)

        guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return false
        }

        let age = Date().timeIntervalSince(modificationDate)
        return age < cacheMaxAge
    }

    /// Clear cached commit history
    func clearCommitHistoryCache() throws {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        let fileURL = directory.appendingPathComponent(cacheFileName)

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    // MARK: - User Settings Cache

    /// Save user settings
    func saveSettings(_ settings: UserSettings) throws {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        let fileURL = directory.appendingPathComponent(settingsFileName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(settings)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw CacheError.failedToWrite
        }
    }

    /// Load user settings
    func loadSettings() throws -> UserSettings {
        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        let fileURL = directory.appendingPathComponent(settingsFileName)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            // Return default settings if file doesn't exist
            return UserSettings()
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: fileURL)
            let settings = try decoder.decode(UserSettings.self, from: data)
            return settings
        } catch {
            // Return default settings if corrupted
            return UserSettings()
        }
    }

    /// Clear all cached data
    func clearAllCache() throws {
        try? clearCommitHistoryCache()

        guard let directory = cacheDirectory else {
            throw CacheError.invalidDirectory
        }

        let settingsURL = directory.appendingPathComponent(settingsFileName)
        if fileManager.fileExists(atPath: settingsURL.path) {
            try fileManager.removeItem(at: settingsURL)
        }
    }
}
