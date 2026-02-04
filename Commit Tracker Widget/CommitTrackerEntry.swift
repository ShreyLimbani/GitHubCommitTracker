//
//  CommitTrackerEntry.swift
//  CommitTrackerWidget
//
//  Widget timeline entry model
//

import WidgetKit
import Foundation

struct CommitTrackerEntry: TimelineEntry {
    let date: Date
    let commitHistory: CommitHistory?
    let streakStats: StreakStatistics
    let username: String?
    let lastUpdateTime: Date?
    let errorMessage: String?

    /// Placeholder entry for widget gallery preview
    static var placeholder: CommitTrackerEntry {
        CommitTrackerEntry(
            date: Date(),
            commitHistory: nil,
            streakStats: .empty,
            username: "Loading...",
            lastUpdateTime: nil,
            errorMessage: nil
        )
    }

    /// Entry for when no data is available
    static var noData: CommitTrackerEntry {
        CommitTrackerEntry(
            date: Date(),
            commitHistory: nil,
            streakStats: .empty,
            username: nil,
            lastUpdateTime: nil,
            errorMessage: "Open app to load data"
        )
    }

    /// Check if data is stale (older than 24 hours)
    var isDataStale: Bool {
        guard let lastUpdate = lastUpdateTime else { return false }
        let hoursSinceUpdate = Date().timeIntervalSince(lastUpdate) / 3600
        return hoursSinceUpdate > 24
    }

    /// Get relative time string for last update
    var lastUpdateText: String {
        guard let lastUpdate = lastUpdateTime else {
            return "Never updated"
        }
        return DateUtilities.relativeTimeString(from: lastUpdate)
    }
}
