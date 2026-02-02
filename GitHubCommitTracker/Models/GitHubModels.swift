//
//  GitHubModels.swift
//  GitHubCommitTracker
//
//  Models for GitHub API responses
//

import Foundation

/// Root response for GraphQL query
struct GitHubGraphQLResponse: Codable {
    let data: GitHubData?
    let errors: [GitHubError]?
}

struct GitHubData: Codable {
    let user: GitHubUser?
}

struct GitHubUser: Codable {
    let login: String?
    let contributionsCollection: ContributionsCollection
}

struct ContributionsCollection: Codable {
    let contributionCalendar: ContributionCalendar
}

struct ContributionCalendar: Codable {
    let totalContributions: Int
    let weeks: [ContributionWeek]
}

struct ContributionWeek: Codable {
    let contributionDays: [ContributionDay]
}

struct ContributionDay: Codable {
    let contributionCount: Int
    let date: String  // Format: "YYYY-MM-DD"
}

struct GitHubError: Codable {
    let message: String
    let type: String?
}

/// REST API response for user info (for token validation)
struct GitHubUserInfo: Codable {
    let login: String
    let id: Int
    let name: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case login
        case id
        case name
        case avatarUrl = "avatar_url"
    }
}
