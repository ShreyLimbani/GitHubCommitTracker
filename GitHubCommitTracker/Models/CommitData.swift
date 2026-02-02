//
//  CommitData.swift
//  GitHubCommitTracker
//
//  Core data models for commit tracking
//

import Foundation

/// Represents a single day's commit activity
struct CommitDay: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let commitCount: Int

    var hasCommits: Bool {
        commitCount > 0
    }

    init(id: UUID = UUID(), date: Date, commitCount: Int) {
        self.id = id
        self.date = date
        self.commitCount = commitCount
    }
}

/// Complete commit history for a user
struct CommitHistory: Codable {
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
}

/// Statistics about commit streaks and activity
struct StreakStatistics {
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

/// User settings and preferences
struct UserSettings: Codable {
    var username: String?
    var hasCompletedOnboarding: Bool
    var lastRefreshDate: Date?
    var refreshInterval: TimeInterval // in seconds

    init(username: String? = nil,
         hasCompletedOnboarding: Bool = false,
         lastRefreshDate: Date? = nil,
         refreshInterval: TimeInterval = 3600 * 3) { // 3 hours default
        self.username = username
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.lastRefreshDate = lastRefreshDate
        self.refreshInterval = refreshInterval
    }

    /// Check if data needs refresh based on interval
    var needsRefresh: Bool {
        guard let lastRefresh = lastRefreshDate else { return true }
        return Date().timeIntervalSince(lastRefresh) > refreshInterval
    }
}
