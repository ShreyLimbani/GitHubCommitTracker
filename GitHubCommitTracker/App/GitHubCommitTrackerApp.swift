//
//  GitHubCommitTrackerApp.swift
//  GitHubCommitTracker
//
//  Main app entry point
//

import SwiftUI

@main
struct GitHubCommitTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // MenuBar apps typically don't need a scene, but we keep this for compatibility
        Settings {
            EmptyView()
        }
    }
}
