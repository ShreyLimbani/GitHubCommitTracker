//
//  MenuBarPopoverView.swift
//  GitHubCommitTracker
//
//  Main popover view displayed from menubar
//

import SwiftUI

struct MenuBarPopoverView: View {
    @Bindable var viewModel: MenuBarViewModel
    @State private var settingsViewModel = SettingsViewModel()

    var body: some View {
        ZStack {
            if viewModel.showSettings {
                // Settings/Onboarding view
                SettingsView(viewModel: settingsViewModel) { token in
                    await viewModel.saveToken(token)
                }
            } else {
                // Main content view
                mainContentView
            }
        }
        .frame(width: Constants.UI.popoverWidth, height: Constants.UI.popoverHeight)
    }

    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, Constants.UI.padding)
                .padding(.vertical, 12)

            Divider()

            // Content area
            ScrollView {
                VStack(spacing: Constants.UI.padding) {
                    // Error message
                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                    }

                    // Calendar
                    CalendarView(viewModel: viewModel)
                        .padding(.top, Constants.UI.padding)

                    // Streak statistics
                    StreakDisplayView(
                        stats: viewModel.streakStats,
                        lastUpdateText: viewModel.lastUpdateText
                    )
                    .padding(.horizontal, Constants.UI.padding)
                }
                .padding(.bottom, Constants.UI.padding)
            }

            // Loading overlay
            if viewModel.isLoading {
                LoadingView(message: "Fetching commits...")
            }
        }
        .background(Constants.Colors.background)
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Constants.Text.appName)
                    .font(.system(size: 14, weight: .semibold))

                if let username = viewModel.settings.username {
                    Text("@\(username)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                // Refresh button
                Button(action: { Task { await viewModel.refreshData() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
                .help("Refresh data")

                // Settings button
                Button(action: { viewModel.showSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .help("Settings")

                // Quit button
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .help("Quit")
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)

            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.primary)

            Spacer()

            Button(action: { viewModel.errorMessage = nil }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(Constants.UI.cornerRadius)
        .padding(.horizontal, Constants.UI.padding)
    }
}

#Preview {
    MenuBarPopoverView(viewModel: MenuBarViewModel())
}
