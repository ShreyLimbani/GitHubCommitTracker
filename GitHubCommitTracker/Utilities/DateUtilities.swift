//
//  DateUtilities.swift
//  GitHubCommitTracker
//
//  Date manipulation and formatting utilities
//

import Foundation

enum DateUtilities {

    /// Get the start of day for a date (normalized to midnight UTC)
    static func startOfDay(for date: Date, calendar: Calendar = .current) -> Date {
        return calendar.startOfDay(for: date)
    }

    /// Check if two dates are on the same day
    static func isSameDay(_ date1: Date, _ date2: Date, calendar: Calendar = .current) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    /// Get the first day of the month for a given date
    static func firstDayOfMonth(for date: Date, calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    /// Get the last day of the month for a given date
    static func lastDayOfMonth(for date: Date, calendar: Calendar = .current) -> Date {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let lastDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDay) else {
            return date
        }
        return lastDay
    }

    /// Get the number of days in a month
    static func daysInMonth(for date: Date, calendar: Calendar = .current) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }

    /// Get an array of all dates in a month
    static func datesInMonth(for date: Date, calendar: Calendar = .current) -> [Date] {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        let daysCount = daysInMonth(for: date, calendar: calendar)
        var dates: [Date] = []

        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                dates.append(date)
            }
        }

        return dates
    }

    /// Get the weekday (1 = Sunday, 7 = Saturday) for a date
    static func weekday(for date: Date, calendar: Calendar = .current) -> Int {
        return calendar.component(.weekday, from: date)
    }

    /// Add or subtract months from a date
    static func addMonths(_ months: Int, to date: Date, calendar: Calendar = .current) -> Date {
        return calendar.date(byAdding: .month, value: months, to: date) ?? date
    }

    /// Format date as "Month Year" (e.g., "January 2026")
    static func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    /// Format date as relative time (e.g., "2 min ago", "1 hour ago")
    static func relativeTimeString(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) min ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }

    /// ISO8601 date formatter for API communication
    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    /// Parse ISO8601 date string
    static func parseISO8601(_ dateString: String) -> Date? {
        return iso8601Formatter.date(from: dateString)
    }

    /// Format date as ISO8601 string
    static func formatISO8601(_ date: Date) -> String {
        return iso8601Formatter.string(from: date)
    }
}
