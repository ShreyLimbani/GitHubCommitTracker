//
//  SmallWidgetView.swift
//  CommitTrackerWidget
//
//  Small widget layout (220×220 pts) - Shows streak statistics
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: CommitTrackerEntry

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
            Spacer()

            // Current streak (large)
            VStack(spacing: 4) {
                Text("\(entry.streakStats.currentStreak)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.commitGreen)

                    Text("Current Streak")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Secondary stats
            VStack(spacing: 8) {
                HStack(spacing: 20) {
                    StatItem(
                        label: "Longest",
                        value: "\(entry.streakStats.longestStreak)",
                        icon: "trophy.fill"
                    )

                    StatItem(
                        label: "Active",
                        value: "\(entry.streakStats.activeDaysThisMonth)",
                        icon: "calendar"
                    )
                }

                // Last update
                if let lastUpdate = entry.lastUpdateTime {
                    Text(timeAgoText(from: lastUpdate))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                        .opacity(0.6)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
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
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("GitHub Commits")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)

            Text(entry.errorMessage ?? "Open app to load data")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.primary)

            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
    }
}

#Preview(as: .systemSmall) {
    CommitTrackerWidget()
} timeline: {
    CommitTrackerEntry.placeholder
}
