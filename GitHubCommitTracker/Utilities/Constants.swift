//
//  Constants.swift
//  GitHubCommitTracker
//
//  App-wide constants and configuration
//

import Foundation
import SwiftUI

enum Constants {

    // MARK: - UI Layout
    enum UI {
        static let popoverWidth: CGFloat = 320
        static let popoverHeight: CGFloat = 440
        static let calendarDaySize: CGFloat = 36
        static let calendarSpacing: CGFloat = 4
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 16
    }

    // MARK: - Colors
    enum Colors {
        static let commitGreen = Color(red: 0.18, green: 0.64, blue: 0.31) // #2ea44f
        static let noCommitGray = Color.gray.opacity(0.2)
        static let todayBorder = Color.blue
        static let background = Color(nsColor: .windowBackgroundColor)
        static let secondaryBackground = Color(nsColor: .controlBackgroundColor)
    }

    // MARK: - Data & Caching
    enum Data {
        static let cacheMaxAge: TimeInterval = 3600 // 1 hour
        static let defaultRefreshInterval: TimeInterval = 3600 * 3 // 3 hours
        static let daysToFetch: Int = 365 // Fetch last year of commits
    }

    // MARK: - API
    enum API {
        static let graphQLEndpoint = "https://api.github.com/graphql"
        static let restEndpoint = "https://api.github.com"
        static let requiredScopes = ["read:user", "repo"]
    }

    // MARK: - URLs
    enum URLs {
        static let newTokenURL = URL(string: "https://github.com/settings/tokens/new")!
        static let tokenHelpURL = URL(string: "https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token")!
    }

    // MARK: - Text
    enum Text {
        static let appName = "GitHub Commit Tracker"
        static let tokenInstructions = """
        To get started, you'll need a GitHub Personal Access Token:

        1. Click the button below to create a token
        2. Give it a name (e.g., "Commit Tracker")
        3. Select scopes: read:user and repo
        4. Generate token and paste it below
        """
        static let tokenPlaceholder = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    }

    // MARK: - Calendar
    enum Calendar {
        static let weekdaySymbols = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        static let monthsToShow = 1
    }
}
