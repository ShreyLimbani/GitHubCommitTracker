//
//  StreakCalculator.swift
//  GitHubCommitTracker
//
//  Calculates commit streaks and statistics
//

import Foundation

enum StreakCalculator {

    /// Calculate comprehensive streak statistics from commit history
    static func calculateStatistics(from history: CommitHistory, currentDate: Date = Date()) -> StreakStatistics {
        let activeDays = history.activeDays().sorted { $0.date < $1.date }

        guard !activeDays.isEmpty else {
            return .empty
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)

        // Calculate current streak
        let currentStreak = calculateCurrentStreak(activeDays: activeDays, today: today, calendar: calendar)

        // Calculate longest streak
        let longestStreak = calculateLongestStreak(activeDays: activeDays, calendar: calendar)

        // Calculate active days this month
        let activeDaysThisMonth = calculateActiveDaysThisMonth(
            activeDays: activeDays,
            currentDate: currentDate,
            calendar: calendar
        )

        // Get last commit date
        let lastCommitDate = activeDays.last?.date

        return StreakStatistics(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            activeDaysThisMonth: activeDaysThisMonth,
            lastCommitDate: lastCommitDate
        )
    }

    /// Calculate current streak (consecutive days up to today or yesterday)
    private static func calculateCurrentStreak(activeDays: [CommitDay], today: Date, calendar: Calendar) -> Int {
        guard !activeDays.isEmpty else { return 0 }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let mostRecentCommit = calendar.startOfDay(for: activeDays.last!.date)

        // Check if most recent commit is today or yesterday
        guard mostRecentCommit == today || mostRecentCommit == yesterday else {
            return 0 // Streak is broken
        }

        // Count consecutive days backwards from most recent
        var streak = 1
        var currentDay = mostRecentCommit

        for day in activeDays.reversed().dropFirst() {
            let dayStart = calendar.startOfDay(for: day.date)
            let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay)!

            if dayStart == previousDay {
                streak += 1
                currentDay = dayStart
            } else {
                break // Gap found, stop counting
            }
        }

        return streak
    }

    /// Calculate longest streak across all history
    private static func calculateLongestStreak(activeDays: [CommitDay], calendar: Calendar) -> Int {
        guard !activeDays.isEmpty else { return 0 }

        var maxStreak = 1
        var currentStreak = 1
        var previousDate = calendar.startOfDay(for: activeDays[0].date)

        for day in activeDays.dropFirst() {
            let dayStart = calendar.startOfDay(for: day.date)
            let expectedNextDay = calendar.date(byAdding: .day, value: 1, to: previousDate)!

            if dayStart == expectedNextDay {
                // Consecutive day
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                // Gap found, reset streak
                currentStreak = 1
            }

            previousDate = dayStart
        }

        return maxStreak
    }

    /// Calculate number of active days in the current month
    private static func calculateActiveDaysThisMonth(activeDays: [CommitDay], currentDate: Date, calendar: Calendar) -> Int {
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)

        return activeDays.filter { day in
            let month = calendar.component(.month, from: day.date)
            let year = calendar.component(.year, from: day.date)
            return month == currentMonth && year == currentYear
        }.count
    }
}
