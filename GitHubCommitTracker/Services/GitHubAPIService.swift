//
//  GitHubAPIService.swift
//  GitHubCommitTracker
//
//  GitHub GraphQL API client for fetching commit data
//

@preconcurrency import Foundation

enum GitHubAPIError: Error {
    case unauthorized
    case rateLimited(resetDate: Date?)
    case networkError(Error)
    case serverError(Int)
    case invalidResponse
    case noData
    case invalidToken
    case unknownUser
    case duplicateAccount

    var localizedDescription: String {
        switch self {
        case .unauthorized:
            return "Invalid GitHub token. Please update your token in settings."
        case .rateLimited(let resetDate):
            if let date = resetDate {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                return "Rate limited. Resets at \(formatter.string(from: date))"
            }
            return "Rate limited. Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .invalidResponse:
            return "Invalid response from GitHub"
        case .noData:
            return "No data received from GitHub"
        case .invalidToken:
            return "Invalid GitHub token"
        case .unknownUser:
            return "User not found on GitHub"
        case .duplicateAccount:
            return "This account has already been added"
        }
    }
}

final class GitHubAPIService {
    private let graphQLEndpoint = URL(string: "https://api.github.com/graphql")!
    private let restEndpoint = URL(string: "https://api.github.com")!
    private let session = URLSession.shared

    /// Validate GitHub token by fetching user info
    func validateToken(_ token: String) async throws -> String {
        let url = restEndpoint.appendingPathComponent("user")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw GitHubAPIError.invalidToken
        }

        guard httpResponse.statusCode == 200 else {
            throw GitHubAPIError.serverError(httpResponse.statusCode)
        }

        let userInfo = try JSONDecoder().decode(GitHubUserInfo.self, from: data)
        return userInfo.login
    }

    /// Fetch commit contributions for a user within a date range
    func fetchContributions(username: String, token: String, from: Date, to: Date) async throws -> [CommitDay] {
        let query = buildGraphQLQuery(username: username, from: from, to: to)

        var request = URLRequest(url: graphQLEndpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["query": query]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.invalidResponse
        }

        // Check rate limiting
        if httpResponse.statusCode == 403 {
            let resetDate = parseRateLimitReset(from: httpResponse)
            throw GitHubAPIError.rateLimited(resetDate: resetDate)
        }

        if httpResponse.statusCode == 401 {
            throw GitHubAPIError.unauthorized
        }

        guard httpResponse.statusCode == 200 else {
            throw GitHubAPIError.serverError(httpResponse.statusCode)
        }

        let graphQLResponse = try JSONDecoder().decode(GitHubGraphQLResponse.self, from: data)

        // Check for GraphQL errors
        if let errors = graphQLResponse.errors, !errors.isEmpty {
            throw GitHubAPIError.invalidResponse
        }

        guard let user = graphQLResponse.data?.user else {
            throw GitHubAPIError.unknownUser
        }

        // Parse contribution days
        let commitDays = parseContributionDays(from: user.contributionsCollection)
        return commitDays
    }

    /// Fetch contributions for the last 365 days
    func fetchRecentContributions(username: String, token: String) async throws -> [CommitDay] {
        let to = Date()
        let from = Calendar.current.date(byAdding: .day, value: -365, to: to)!
        return try await fetchContributions(username: username, token: token, from: from, to: to)
    }

    // MARK: - Private Helpers

    private func buildGraphQLQuery(username: String, from: Date, to: Date) -> String {
        let dateFormatter = ISO8601DateFormatter()
        let fromString = dateFormatter.string(from: from)
        let toString = dateFormatter.string(from: to)

        return """
        query {
          user(login: "\(username)") {
            contributionsCollection(from: "\(fromString)", to: "\(toString)") {
              contributionCalendar {
                totalContributions
                weeks {
                  contributionDays {
                    contributionCount
                    date
                  }
                }
              }
            }
          }
        }
        """
    }

    private func parseContributionDays(from collection: ContributionsCollection) -> [CommitDay] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        var commitDays: [CommitDay] = []

        for week in collection.contributionCalendar.weeks {
            for day in week.contributionDays {
                guard let date = dateFormatter.date(from: day.date) else {
                    continue
                }

                let commitDay = CommitDay(
                    date: date,
                    commitCount: day.contributionCount
                )
                commitDays.append(commitDay)
            }
        }

        return commitDays
    }

    private func parseRateLimitReset(from response: HTTPURLResponse) -> Date? {
        guard let resetString = response.value(forHTTPHeaderField: "X-RateLimit-Reset"),
              let resetTimestamp = TimeInterval(resetString) else {
            return nil
        }
        return Date(timeIntervalSince1970: resetTimestamp)
    }
}
