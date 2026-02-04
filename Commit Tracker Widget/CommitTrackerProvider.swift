//
//  CommitTrackerProvider.swift
//  CommitTrackerWidget
//
//  Widget timeline provider - loads data from shared cache
//

import WidgetKit
import SwiftUI

struct CommitTrackerProvider: TimelineProvider {

    /// Provide placeholder entry for widget gallery
    func placeholder(in context: Context) -> CommitTrackerEntry {
        .placeholder
    }

    /// Provide snapshot for widget gallery preview
    func getSnapshot(in context: Context, completion: @escaping (CommitTrackerEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    /// Provide timeline with scheduled updates
    func getTimeline(in context: Context, completion: @escaping (Timeline<CommitTrackerEntry>) -> Void) {
        let currentDate = Date()
        let entry = loadEntry()

        // Schedule next refresh in 30 minutes
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!

        // Create timeline with single entry and automatic refresh policy
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))

        completion(timeline)
    }

    /// Load entry from shared cache
    private func loadEntry() -> CommitTrackerEntry {
        let cacheManager = CacheManager(useSharedContainer: true)

        // Try to load app settings and commit history
        guard let appSettings = try? cacheManager.loadAppSettings(),
              let activeAccountId = appSettings.activeAccountId,
              let history = try? cacheManager.loadCommitHistory(for: activeAccountId) else {
            // No data available
            return .noData
        }

        // Calculate statistics
        let stats = StreakCalculator.calculateStatistics(from: history)

        // Create entry with loaded data
        return CommitTrackerEntry(
            date: Date(),
            commitHistory: history,
            streakStats: stats,
            username: history.username,
            lastUpdateTime: history.lastFetched,
            errorMessage: nil
        )
    }
}
