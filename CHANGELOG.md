# Changelog

All notable changes to GitHub Commit Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-05

### Added
- Initial beta release of GitHub Commit Tracker
- Native macOS MenuBar application for tracking GitHub commit activity
- GitHub GraphQL API integration for fetching commit data
- Visual commit calendar showing contribution activity
- Streak tracking (current streak, longest streak, active days)
- Secure token storage using macOS Keychain
- Local caching with 1-hour cache duration
- Multiple account support with account switching
- Enhanced settings panel with:
  - Account management (add/remove accounts)
  - Appearance customization (light/dark/system mode)
  - Data management (clear cache, view storage info)
  - About section with app info
- macOS Desktop Widgets (3 sizes):
  - Small widget: Streak statistics display
  - Medium widget: Full month calendar grid with streak stats
  - Large widget: Comprehensive calendar and detailed statistics
- Widget data sharing via App Groups
- Automatic widget updates when app refreshes data
- 30-minute widget auto-refresh timeline

### Technical Details
- Built with Swift 5.9+ and SwiftUI
- Minimum requirement: macOS 13.0 (Ventura)
- Widget requirement: macOS 14.0+
- Uses native frameworks only (no third-party dependencies)
- Keychain integration for secure credential storage
- App Groups for widget data sharing
- GraphQL API queries for efficient data fetching

### Documentation
- Comprehensive README with setup instructions
- Xcode setup guide for building from source
- Implementation summary documenting all features
- Project structure documentation
