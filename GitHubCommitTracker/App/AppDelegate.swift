//
//  AppDelegate.swift
//  GitHubCommitTracker
//
//  MenuBar app management and popover configuration
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var viewModel: MenuBarViewModel?

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create view model
        viewModel = MenuBarViewModel()

        // Set up menu bar item
        setupMenuBar()

        // Set up popover
        setupPopover()

        // Configure app to not show in Dock
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup if needed
    }

    // MARK: - MenuBar Setup

    private func setupMenuBar() {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else {
            print("Failed to create status bar button")
            return
        }

        // Set icon (using SF Symbol)
        if let image = NSImage(systemSymbolName: "chart.bar.fill", accessibilityDescription: "GitHub Commits") {
            image.isTemplate = true // Allows it to adapt to menu bar theme
            button.image = image
        } else {
            // Fallback text if symbol not available
            button.title = "GH"
        }

        // Set button action
        button.action = #selector(togglePopover)
        button.target = self
    }

    // MARK: - Popover Setup

    private func setupPopover() {
        guard let viewModel = viewModel else { return }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: Constants.UI.popoverWidth, height: Constants.UI.popoverHeight)
        popover?.behavior = .transient // Closes when clicking outside
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView(viewModel: viewModel)
        )
    }

    // MARK: - Popover Actions

    @objc private func togglePopover() {
        guard let popover = popover,
              let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Activate app to make popover key window
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func showPopover() {
        guard let popover = popover,
              let button = statusItem?.button else { return }

        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func hidePopover() {
        popover?.performClose(nil)
    }
}
