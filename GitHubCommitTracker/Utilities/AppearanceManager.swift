//
//  AppearanceManager.swift
//  GitHubCommitTracker
//
//  Manages app appearance (Light/Dark/System mode)
//

import SwiftUI
import AppKit
import Combine

@MainActor
final class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()

    @Published private(set) var currentMode: AppearanceMode = .system

    private init() {
        // Private initializer for singleton
        // Apply the initial appearance (system default)
        applyAppearance(currentMode)
    }

    /// Set the app appearance mode
    func setAppearance(_ mode: AppearanceMode) {
        currentMode = mode
        applyAppearance(mode)
        // Trigger UI update for system mode to pick up actual system appearance
        objectWillChange.send()
    }

    /// Apply the appearance to the app
    private func applyAppearance(_ mode: AppearanceMode) {
        switch mode {
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        case .system:
            NSApp.appearance = nil // System default
        }
    }

    /// Get the SwiftUI ColorScheme for the current mode
    var colorScheme: ColorScheme? {
        switch currentMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            // Detect and return the actual system appearance
            return systemColorScheme
        }
    }

    /// Detect the current system color scheme
    private var systemColorScheme: ColorScheme {
        let appearance = NSApp.effectiveAppearance
        if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return .dark
        } else {
            return .light
        }
    }

    /// Load appearance from settings and apply
    func loadFromSettings(_ mode: AppearanceMode) {
        currentMode = mode
        applyAppearance(mode)
    }
}
