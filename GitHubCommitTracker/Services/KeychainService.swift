//
//  KeychainService.swift
//  GitHubCommitTracker
//
//  Secure storage for GitHub access token using macOS Keychain
//

import Foundation
import Security

enum KeychainError: Error {
    case failedToSave
    case failedToLoad
    case failedToDelete
    case itemNotFound
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

enum KeychainService {
    private static let service = "com.github-commit-tracker"
    private static let account = "github-token" // Legacy account identifier

    // MARK: - Legacy Methods (for migration compatibility only)

    /// Load GitHub token from keychain (Legacy - used by migration only)
    static func loadToken() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unhandledError(status: status)
        }

        guard let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }

        return token
    }

    /// Check if token exists in keychain (Legacy - used by migration only)
    static func hasToken() -> Bool {
        do {
            _ = try loadToken()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Per-Account Methods

    /// Save GitHub token for a specific account
    static func saveToken(_ token: String, for accountId: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }

        let accountIdentifier = "github-token-\(accountId)"

        // Delete any existing token for this account first
        try? deleteToken(for: accountId)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountIdentifier,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    /// Load GitHub token for a specific account
    static func loadToken(for accountId: String) throws -> String {
        let accountIdentifier = "github-token-\(accountId)"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountIdentifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unhandledError(status: status)
        }

        guard let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }

        return token
    }

    /// Delete GitHub token for a specific account
    static func deleteToken(for accountId: String) throws {
        let accountIdentifier = "github-token-\(accountId)"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountIdentifier
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    /// Check if token exists for a specific account
    static func hasToken(for accountId: String) -> Bool {
        do {
            _ = try loadToken(for: accountId)
            return true
        } catch {
            return false
        }
    }
}
