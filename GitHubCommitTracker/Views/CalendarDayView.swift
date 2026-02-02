//
//  CalendarDayView.swift
//  GitHubCommitTracker
//
//  Individual day cell in the calendar grid
//

import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let commitCount: Int
    let isToday: Bool
    let isCurrentMonth: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text("\(day)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isCurrentMonth ? .primary : .secondary.opacity(0.5))

            Circle()
                .fill(backgroundColor)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .strokeBorder(Constants.Colors.todayBorder, lineWidth: 2)
                        .opacity(isToday ? 1 : 0)
                )
        }
        .frame(width: Constants.UI.calendarDaySize, height: Constants.UI.calendarDaySize)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isToday ? Constants.Colors.todayBorder.opacity(0.1) : Color.clear)
        )
        .help(tooltipText)
    }

    private var day: Int {
        Calendar.current.component(.day, from: date)
    }

    private var backgroundColor: Color {
        if !isCurrentMonth {
            return Color.gray.opacity(0.1)
        }
        return hasCommits ? Constants.Colors.commitGreen : Constants.Colors.noCommitGray
    }

    private var hasCommits: Bool {
        commitCount > 0
    }

    private var tooltipText: String {
        let dateString = DateUtilities.monthYearString(from: date) + " \(day)"
        if hasCommits {
            return "\(dateString)\n\(commitCount) commit\(commitCount == 1 ? "" : "s")"
        } else {
            return "\(dateString)\nNo commits"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            CalendarDayView(date: Date(), commitCount: 0, isToday: false, isCurrentMonth: true)
            CalendarDayView(date: Date(), commitCount: 5, isToday: false, isCurrentMonth: true)
            CalendarDayView(date: Date(), commitCount: 0, isToday: true, isCurrentMonth: true)
            CalendarDayView(date: Date(), commitCount: 3, isToday: true, isCurrentMonth: true)
        }

        HStack(spacing: 10) {
            CalendarDayView(date: Date(), commitCount: 0, isToday: false, isCurrentMonth: false)
            CalendarDayView(date: Date(), commitCount: 5, isToday: false, isCurrentMonth: false)
        }
    }
    .padding()
}
