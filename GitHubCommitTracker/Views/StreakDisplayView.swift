//
//  StreakDisplayView.swift
//  GitHubCommitTracker
//
//  Statistics panel showing streaks and activity
//

import SwiftUI

struct StreakDisplayView: View {
    let stats: StreakStatistics
    let lastUpdateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                StatRow(
                    icon: "calendar",
                    label: "Active Days This Month",
                    value: "\(stats.activeDaysThisMonth)"
                )

                StatRow(
                    icon: "flame.fill",
                    label: "Current Streak",
                    value: "\(stats.currentStreak) day\(stats.currentStreak == 1 ? "" : "s")"
                )

                StatRow(
                    icon: "trophy.fill",
                    label: "Longest Streak",
                    value: "\(stats.longestStreak) day\(stats.longestStreak == 1 ? "" : "s")"
                )
            }

            Divider()

            Text(lastUpdateText)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(Constants.UI.padding)
        .background(Constants.Colors.secondaryBackground)
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
        }
    }

    private var iconColor: Color {
        switch icon {
        case "flame.fill":
            return .orange
        case "trophy.fill":
            return .yellow
        default:
            return .blue
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakDisplayView(
            stats: StreakStatistics(
                currentStreak: 5,
                longestStreak: 23,
                activeDaysThisMonth: 12,
                lastCommitDate: Date()
            ),
            lastUpdateText: "Last updated: 2 min ago"
        )

        StreakDisplayView(
            stats: .empty,
            lastUpdateText: "Never updated"
        )
    }
    .frame(width: Constants.UI.popoverWidth)
    .padding()
}
