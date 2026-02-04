//
//  LargeWidgetView.swift
//  CommitTrackerWidget
//
//  Large widget layout (468×468 pts) - Shows full calendar + stats
//

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: CommitTrackerEntry
    private let calendar = Calendar.current
    private let today = Date()

    var body: some View {
        if entry.errorMessage != nil || entry.username == nil {
            // No data state
            noDataView
        } else {
            // Data view
            dataView
        }
    }

    private var dataView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if let username = entry.username {
                    Text("@\(username)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Text(DateUtilities.monthYearString(from: today))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            // Weekday header
            HStack(spacing: 4) {
                ForEach(Constants.Calendar.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: Constants.UI.calendarDaySize)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)

            // Calendar grid
            calendarGrid
                .padding(.horizontal, 16)

            Spacer()
                .frame(height: 12)

            Divider()
                .padding(.horizontal, 16)

            // Statistics panel
            statsPanel
                .padding(16)
        }
    }

    private var calendarGrid: some View {
        let weeks = generateWeeks()

        return VStack(spacing: 4) {
            ForEach(0..<weeks.count, id: \.self) { weekIndex in
                HStack(spacing: 4) {
                    ForEach(0..<weeks[weekIndex].count, id: \.self) { dayIndex in
                        let date = weeks[weekIndex][dayIndex]
                        if let date = date {
                            WidgetDayView(
                                date: date,
                                commitCount: commitCount(for: date),
                                isToday: calendar.isDateInToday(date),
                                isCurrentMonth: isInCurrentMonth(date)
                            )
                        } else {
                            // Empty cell
                            Color.clear
                                .frame(
                                    width: Constants.UI.calendarDaySize,
                                    height: Constants.UI.calendarDaySize
                                )
                        }
                    }
                }
            }
        }
    }

    private var statsPanel: some View {
        HStack(spacing: 0) {
            // Active days this month
            StatColumn(
                icon: "calendar",
                value: "\(entry.streakStats.activeDaysThisMonth)",
                label: "Active Days",
                color: .blue
            )

            Divider()
                .padding(.vertical, 8)

            // Current streak
            StatColumn(
                icon: "flame.fill",
                value: "\(entry.streakStats.currentStreak)",
                label: "Current Streak",
                color: Constants.Colors.commitGreen
            )

            Divider()
                .padding(.vertical, 8)

            // Longest streak
            StatColumn(
                icon: "trophy.fill",
                value: "\(entry.streakStats.longestStreak)",
                label: "Longest Streak",
                color: .orange
            )
        }
        .frame(height: 60)
    }

    private var noDataView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("GitHub Commits")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            Text(entry.errorMessage ?? "Open app to load data")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helper Methods

    private func generateWeeks() -> [[Date?]] {
        let firstDayOfMonth = DateUtilities.firstDayOfMonth(for: today, calendar: calendar)
        let daysInMonth = DateUtilities.daysInMonth(for: today, calendar: calendar)

        // Get the weekday of the first day (1 = Sunday, 7 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingEmptyDays = firstWeekday - 1

        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = []

        // Add leading empty days
        for _ in 0..<leadingEmptyDays {
            currentWeek.append(nil)
        }

        // Add all days in the month
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDayOfMonth) {
                currentWeek.append(date)

                // Start new week on Sunday
                if currentWeek.count == 7 {
                    weeks.append(currentWeek)
                    currentWeek = []
                }
            }
        }

        // Add trailing empty days to complete the last week
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }

        return weeks
    }

    private func commitCount(for date: Date) -> Int {
        guard let history = entry.commitHistory else { return 0 }
        return history.commits(for: date)?.commitCount ?? 0
    }

    private func isInCurrentMonth(_ date: Date) -> Bool {
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)
        let dateMonth = calendar.component(.month, from: date)
        let dateYear = calendar.component(.year, from: date)

        return currentMonth == dateMonth && currentYear == dateYear
    }
}

struct WidgetDayView: View {
    let date: Date
    let commitCount: Int
    let isToday: Bool
    let isCurrentMonth: Bool
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 2) {
            // Day number
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isCurrentMonth ? .primary : .secondary.opacity(0.5))

            // Commit indicator
            Circle()
                .fill(commitCount > 0 ? Constants.Colors.commitGreen : Constants.Colors.noCommitGray)
                .frame(width: 8, height: 8)
        }
        .frame(width: Constants.UI.calendarDaySize, height: Constants.UI.calendarDaySize)
        .background(isToday ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1.5)
        )
    }
}

struct StatColumn: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview(as: .systemLarge) {
    CommitTrackerWidget()
} timeline: {
    CommitTrackerEntry.placeholder
}
