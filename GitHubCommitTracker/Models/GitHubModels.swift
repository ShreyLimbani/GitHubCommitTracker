//
//  GitHubModels.swift
//  GitHubCommitTracker
//
//  Models for GitHub API responses
//

@preconcurrency import Foundation

/// Root response for GraphQL query
struct GitHubGraphQLResponse: Codable, Sendable {
    let data: GitHubData?
    let errors: [GitHubError]?
}

struct GitHubData: Codable, Sendable {
    let user: GitHubUser?
}

struct GitHubUser: Codable, Sendable {
    let login: String?
    let contributionsCollection: ContributionsCollection
}

struct ContributionsCollection: Codable, Sendable {
    let contributionCalendar: ContributionCalendar
}

struct ContributionCalendar: Codable, Sendable {
    let totalContributions: Int
    let weeks: [ContributionWeek]
}

struct ContributionWeek: Codable, Sendable {
    let contributionDays: [ContributionDay]
}

struct ContributionDay: Codable, Sendable {
    let contributionCount: Int
    let date: String  // Format: "YYYY-MM-DD"
}

struct GitHubError: Codable, Sendable {
    let message: String
    let type: String?
}

/// REST API response for user info (for token validation)
struct GitHubUserInfo: Codable, Sendable {
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
