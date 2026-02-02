//
//  SettingsViewModel.swift
//  GitHubCommitTracker
//
//  Handles settings and token validation logic
//

import Foundation
import SwiftUI

@MainActor
@Observable
class SettingsViewModel {

    // MARK: - Published State
    var tokenInput: String = ""
    var isValidating: Bool = false
    var validationError: String?
    var validationSuccess: Bool = false

    // MARK: - Services
    private let apiService = GitHubAPIService()

    // MARK: - Validation

    var isTokenValid: Bool {
        // GitHub Personal Access Token format: ghp_ followed by 36 characters
        let pattern = "^ghp_[A-Za-z0-9]{36}$"
        return tokenInput.range(of: pattern, options: .regularExpression) != nil
    }

    var canValidate: Bool {
        !tokenInput.isEmpty && !isValidating
    }

    // MARK: - Actions

    func validateToken() async throws -> String {
        guard !tokenInput.isEmpty else {
            throw ValidationError.emptyToken
        }

        isValidating = true
        validationError = nil
        validationSuccess = false

        do {
            let username = try await apiService.validateToken(tokenInput)
            validationSuccess = true
            isValidating = false
            return username
        } catch let error as GitHubAPIError {
            validationError = error.localizedDescription
            isValidating = false
            throw error
        } catch {
            validationError = "Validation failed: \(error.localizedDescription)"
            isValidating = false
            throw error
        }
    }

    func clearValidation() {
        validationError = nil
        validationSuccess = false
    }

    func openGitHubTokenPage() {
        NSWorkspace.shared.open(Constants.URLs.newTokenURL)
    }

    func openTokenHelpPage() {
        NSWorkspace.shared.open(Constants.URLs.tokenHelpURL)
    }
}

enum ValidationError: Error {
    case emptyToken
    case invalidFormat

    var localizedDescription: String {
        switch self {
        case .emptyToken:
            return "Please enter a token"
        case .invalidFormat:
            return "Invalid token format"
        }
    }
}
