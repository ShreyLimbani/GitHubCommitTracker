# GitHub Commit Tracker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version 0.1.0](https://img.shields.io/badge/Version-0.1.0-blue.svg)](https://github.com/ShreyLimbani/GitHubCommitTracker/releases/tag/v0.1.0)

A native macOS MenuBar app that tracks your GitHub commits and displays streaks.

## Features

- 📅 Calendar view showing commit activity
- 🔥 Current streak tracking
- 🏆 Longest streak tracking
- 📊 Monthly active days count
- 💾 Smart caching for instant loading
- 🔒 Secure token storage using macOS Keychain
- 🎨 Light/Dark/System appearance modes
- 🔄 Multiple account support
- 📱 macOS Desktop Widgets (small, medium, large)

## Tech Stack

- **Platform**: Native macOS MenuBar app
- **Language**: Swift with SwiftUI
- **Data Source**: GitHub GraphQL API
- **Minimum OS**: macOS 13.0 (Ventura)
- **Widget Support**: macOS 14.0+ (Sonoma)
- **Dependencies**: Zero (using native frameworks only)

## Installation

### Option 1: Download Release (Recommended)
1. Download the latest release from [Releases](https://github.com/ShreyLimbani/GitHubCommitTracker/releases)
2. Unzip the downloaded file
3. Drag `GitHubCommitTracker.app` to your Applications folder
4. **Important**: Since this app is not code-signed, you'll see a security warning. To bypass:
   - **Right-click** (or Control+click) on `GitHubCommitTracker.app`
   - Select **"Open"** from the menu
   - Click **"Open"** in the security dialog
   - The app will now be trusted for future launches
5. Grant necessary permissions when prompted
6. Add your GitHub personal access token in Settings

> **Note**: The "unidentified developer" warning appears because this is an unsigned app. This is normal for open-source macOS apps distributed outside the Mac App Store. You can verify the source code in this repository.

### Option 2: Build from Source
1. Clone this repository:
   ```bash
   git clone https://github.com/ShreyLimbani/GitHubCommitTracker.git
   cd GitHubCommitTracker
   ```
2. See [XCODE_SETUP_GUIDE.md](XCODE_SETUP_GUIDE.md) for detailed build instructions
3. Or simply open `GitHubCommitTracker.xcodeproj` in Xcode and build

## Setup

1. **Get GitHub Token**:
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Click "Generate new token (classic)"
   - Give it a descriptive name (e.g., "Commit Tracker")
   - Select scope: `read:user` (minimum required)
   - Generate and copy the token

2. **Configure App**:
   - Click the menu bar icon (top-right of screen)
   - Select Settings
   - Paste your GitHub token
   - Click Save

3. **Add Widgets** (Optional):
   - Right-click on your desktop
   - Select "Edit Widgets"
   - Search for "GitHub Commits"
   - Choose your preferred widget size
   - Click "Add Widget"

## Troubleshooting

### "Apple could not verify..." Security Warning

If you see a warning about an unidentified developer, use one of these methods:

**Method 1: Right-Click to Open** (Easiest)
- Right-click the app → Select "Open" → Click "Open" in dialog

**Method 2: Remove Quarantine Attribute**
```bash
xattr -cr /Applications/GitHubCommitTracker.app
```

**Method 3: System Settings**
- Try to open the app (it will be blocked)
- Go to System Settings → Privacy & Security
- Click "Open Anyway" next to the blocked app message

This warning appears because the app is not code-signed with an Apple Developer certificate. The app is safe and open-source (you can review all code in this repository).

## Development Status

✅ Version 0.1.0 - Initial Beta Release

## Documentation

- [Implementation Summary](IMPLEMENTATION_SUMMARY.md) - Complete feature documentation
- [Project Structure](PROJECT_STRUCTURE.md) - Architecture overview
- [Xcode Setup Guide](XCODE_SETUP_GUIDE.md) - Build from source instructions

## Version History

- **v0.1.0** (2026-02-05) - Initial beta release

## License

MIT - See [LICENSE](LICENSE) file for details.
