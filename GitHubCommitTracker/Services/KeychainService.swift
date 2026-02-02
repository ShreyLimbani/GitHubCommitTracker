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
    private static let account = "github-token"

    /// Save GitHub token to keychain
    static func saveToken(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }

        // Delete any existing token first
        try? deleteToken()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    /// Load GitHub token from keychain
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

    /// Delete GitHub token from keychain
    static func deleteToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    /// Check if token exists in keychain
    static func hasToken() -> Bool {
        do {
            _ = try loadToken()
            return true
        } catch {
            return false
        }
    }
}
