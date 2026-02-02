//
//  CalendarView.swift
//  GitHubCommitTracker
//
//  Calendar grid displaying commit activity
//

import SwiftUI

struct CalendarView: View {
    let viewModel: MenuBarViewModel
    let calendar = Calendar.current
    let today = Date()

    var body: some View {
        VStack(spacing: Constants.UI.calendarSpacing) {
            // Month navigation header
            monthHeader

            // Weekday labels
            weekdayHeader

            // Calendar grid
            calendarGrid
        }
    }

    private var monthHeader: some View {
        HStack {
            Button(action: { viewModel.navigateMonth(offset: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(DateUtilities.monthYearString(from: viewModel.selectedMonth))
                .font(.system(size: 16, weight: .semibold))

            Spacer()

            Button(action: { viewModel.navigateMonth(offset: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.UI.padding)
    }

    private var weekdayHeader: some View {
        HStack(spacing: Constants.UI.calendarSpacing) {
            ForEach(Constants.Calendar.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: Constants.UI.calendarDaySize)
            }
        }
        .padding(.horizontal, Constants.UI.padding)
    }

    private var calendarGrid: some View {
        let weeks = generateWeeks()

        return VStack(spacing: Constants.UI.calendarSpacing) {
            ForEach(0..<weeks.count, id: \.self) { weekIndex in
                HStack(spacing: Constants.UI.calendarSpacing) {
                    ForEach(0..<weeks[weekIndex].count, id: \.self) { dayIndex in
                        let date = weeks[weekIndex][dayIndex]
                        if let date = date {
                            CalendarDayView(
                                date: date,
                                commitCount: viewModel.commitCount(for: date),
                                isToday: calendar.isDateInToday(date),
                                isCurrentMonth: isInSelectedMonth(date)
                            )
                        } else {
                            // Empty cell for alignment
                            Color.clear
                                .frame(width: Constants.UI.calendarDaySize, height: Constants.UI.calendarDaySize)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Constants.UI.padding)
    }

    // MARK: - Helpers

    private func generateWeeks() -> [[Date?]] {
        let firstDayOfMonth = DateUtilities.firstDayOfMonth(for: viewModel.selectedMonth, calendar: calendar)
        let daysInMonth = DateUtilities.daysInMonth(for: viewModel.selectedMonth, calendar: calendar)

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

                // Start new week on Sunday (when count reaches 7)
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

    private func isInSelectedMonth(_ date: Date) -> Bool {
        let selectedMonth = calendar.component(.month, from: viewModel.selectedMonth)
        let selectedYear = calendar.component(.year, from: viewModel.selectedMonth)
        let dateMonth = calendar.component(.month, from: date)
        let dateYear = calendar.component(.year, from: date)

        return selectedMonth == dateMonth && selectedYear == dateYear
    }
}

#Preview {
    CalendarView(viewModel: MenuBarViewModel())
        .frame(width: Constants.UI.popoverWidth)
        .padding()
}
