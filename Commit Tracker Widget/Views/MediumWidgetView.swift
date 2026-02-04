//
//  MediumWidgetView.swift
//  CommitTrackerWidget
//
//  Medium widget layout (468×220 pts) - Shows compact calendar + stats
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: CommitTrackerEntry
    private let calendar = Calendar.current

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
        HStack(spacing: 0) {
            // Left: Full month calendar
            VStack(alignment: .leading, spacing: 5) {
                // Header
                HStack {
                    if let username = entry.username {
                        Text("@\(username)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Text(DateUtilities.monthYearString(from: Date()))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                // Weekday labels
                HStack(spacing: 4) {
                    ForEach(Constants.Calendar.weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 19)
                    }
                }

                // Full month calendar
                VStack(spacing: 4) {
                    ForEach(generateWeeks(), id: \.self) { week in
                        HStack(spacing: 4) {
                            ForEach(week, id: \.self) { date in
                                if let date = date {
                                    CompactDayView(
                                        date: date,
                                        commitCount: commitCount(for: date),
                                        isToday: calendar.isDateInToday(date)
                                    )
                                } else {
                                    // Empty cell for padding
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 19, height: 19)
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Last update
                if let lastUpdate = entry.lastUpdateTime {
                    Text(timeAgoText(from: lastUpdate))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.primary)
                        .opacity(0.6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)

            Divider()

            // Right: Stats
            VStack(spacing: 8) {
                // Current streak
                VStack(spacing: 2) {
                    Text("\(entry.streakStats.currentStreak)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)

                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 8))
                            .foregroundColor(Constants.Colors.commitGreen)

                        Text("Current")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                Divider()
                    .padding(.horizontal, 6)

                // Longest streak
                VStack(spacing: 2) {
                    Text("\(entry.streakStats.longestStreak)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                    HStack(spacing: 2) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 7))
                            .foregroundColor(.orange)

                        Text("Longest")
                            .font(.system(size: 7, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 85, alignment: .center)
            .frame(maxHeight: .infinity, alignment: .center)
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
        }
        .padding(12)
    }

    /// Generate weeks for the current month calendar
    private func generateWeeks() -> [[Date?]] {
        let today = Date()
        guard let monthInterval = calendar.dateInterval(of: .month, for: today),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }

        var weeks: [[Date?]] = []
        var currentDate = monthFirstWeek.start

        while currentDate <= monthLastWeek.start {
            var week: [Date?] = []

            for _ in 0..<7 {
                if calendar.isDate(currentDate, equalTo: monthInterval.start, toGranularity: .month) {
                    week.append(currentDate)
                } else {
                    week.append(nil)
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }

            weeks.append(week)
        }

        return weeks
    }

    private func timeAgoText(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 24 {
            let days = hours / 24
            return "Updated \(days)d ago"
        } else if hours > 0 {
            return "Updated \(hours)h ago"
        } else if minutes > 0 {
            return "Updated \(minutes)m ago"
        } else {
            return "Updated just now"
        }
    }

    private var noDataView: some View {
        HStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("GitHub Commits")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Text(entry.errorMessage ?? "Open app to load data")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
    }

    private func commitCount(for date: Date) -> Int {
        guard let history = entry.commitHistory else { return 0 }
        return history.commits(for: date)?.commitCount ?? 0
    }
}

struct CompactDayView: View {
    let date: Date
    let commitCount: Int
    let isToday: Bool

    var body: some View {
        Circle()
            .fill(commitCount > 0 ? Constants.Colors.commitGreen : Constants.Colors.noCommitGray)
            .frame(width: 19, height: 19)
            .overlay(
                Circle()
                    .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1.5)
            )
    }
}

#Preview(as: .systemMedium) {
    CommitTrackerWidget()
} timeline: {
    CommitTrackerEntry.placeholder
}
