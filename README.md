# GitHub Commit Tracker

A native macOS MenuBar app that tracks your GitHub commits and displays streaks.

## Features

- 📅 Calendar view showing commit activity
- 🔥 Current streak tracking
- 🏆 Longest streak tracking
- 📊 Monthly active days count
- 💾 Smart caching for instant loading
- 🔒 Secure token storage using macOS Keychain

## Tech Stack

- **Platform**: Native macOS MenuBar app
- **Language**: Swift with SwiftUI
- **Data Source**: GitHub GraphQL API
- **Minimum OS**: macOS 13.0 (Ventura)
- **Dependencies**: Zero (using native frameworks only)

## Setup

1. Clone this repository
2. Open the Xcode project
3. Build and run
4. On first launch, you'll be prompted to create a GitHub Personal Access Token
5. Required scopes: `read:user`, `repo`

## Development Status

🚧 In active development

## License

MIT
