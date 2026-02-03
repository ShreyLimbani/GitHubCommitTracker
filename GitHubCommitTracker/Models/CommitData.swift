//
//  CommitData.swift
//  GitHubCommitTracker
//
//  Core data models for commit tracking
//

@preconcurrency import Foundation

/// Represents a single day's commit activity
struct CommitDay: Codable, Identifiable, Equatable, Sendable {
    let id: UUID = UUID()
    let date: Date
    let commitCount: Int

    var hasCommits: Bool {
        commitCount > 0
    }
}

/// Complete commit history for a user
struct CommitHistory: Codable, Sendable {
    let username: String
    let days: [CommitDay]
    let lastFetched: Date

    /// Get commit days for a specific month
    func daysInMonth(_ date: Date) -> [CommitDay] {
        let calendar = Calendar.current
        let targetMonth = calendar.component(.month, from: date)
        let targetYear = calendar.component(.year, from: date)

        return days.filter { day in
            let month = calendar.component(.month, from: day.date)
            let year = calendar.component(.year, from: day.date)
            return month == targetMonth && year == targetYear
        }
    }

    /// Get commit days within a date range (inclusive)
    func daysInRange(from: Date, to: Date) -> [CommitDay] {
        return days.filter { day in
            day.date >= from && day.date <= to
        }
    }

    /// Get all days with commits
    func activeDays() -> [CommitDay] {
        return days.filter { $0.hasCommits }
    }

    /// Get commit day for a specific date
    func commits(for date: Date) -> CommitDay? {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)

        return days.first { day in
            calendar.startOfDay(for: day.date) == targetDay
        }
    }
}

/// Statistics about commit streaks and activity
struct StreakStatistics: Sendable {
    let currentStreak: Int
    let longestStreak: Int
    let activeDaysThisMonth: Int
    let lastCommitDate: Date?

    /// Create empty statistics (no commits)
    static var empty: StreakStatistics {
        StreakStatistics(
            currentStreak: 0,
            longestStreak: 0,
            activeDaysThisMonth: 0,
            lastCommitDate: nil
        )
    }
}

/// User settings and preferences (Legacy - kept for migration compatibility)
struct UserSettings: Codable, Sendable {
    var username: String? = nil
    var hasCompletedOnboarding: Bool = false
    var lastRefreshDate: Date? = nil
    var refreshInterval: TimeInterval = 3600 * 3 // 3 hours default

    /// Check if data needs refresh based on interval
    var needsRefresh: Bool {
        guard let lastRefresh = lastRefreshDate else { return true }
        return Date().timeIntervalSince(lastRefresh) > refreshInterval
    }
}

/// Appearance mode for the app
enum AppearanceMode: String, Codable, CaseIterable, Sendable {
    case light
    case dark
    case system

    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

/// Represents a GitHub account in the app
struct GitHubAccount: Codable, Identifiable, Equatable, Sendable {
    let id: String           // username (unique identifier)
    let username: String
    let displayName: String?
    let dateAdded: Date
    var isActive: Bool

    init(username: String, displayName: String? = nil, dateAdded: Date = Date(), isActive: Bool = true) {
        self.id = username
        self.username = username
        self.displayName = displayName
        self.dateAdded = dateAdded
        self.isActive = isActive
    }
}

/// App-wide settings supporting multiple accounts
struct AppSettings: Codable, Sendable {
    var accounts: [GitHubAccount] = []
    var activeAccountId: String?
    var appearanceMode: AppearanceMode = .system
    var hasCompletedOnboarding: Bool = false
    var refreshInterval: TimeInterval = 3600 * 3 // 3 hours default

    /// Get the currently active account
    var activeAccount: GitHubAccount? {
        guard let accountId = activeAccountId else { return nil }
        return accounts.first { $0.id == accountId }
    }

    /// Check if the app has at least one account
    var hasAccounts: Bool {
        !accounts.isEmpty
    }
}
