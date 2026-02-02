# Xcode Project Setup Guide

All the Swift code for the GitHub Commit Tracker MenuBar app has been implemented. Now you need to create an Xcode project to build and run the app.

## Step 1: Create New Xcode Project

1. Open **Xcode**
2. Select **File → New → Project** (or press `⌘⇧N`)
3. Choose **macOS → App**
4. Click **Next**

## Step 2: Project Configuration

Configure the project with these settings:

- **Product Name**: `GitHubCommitTracker`
- **Team**: Select your Apple Developer account (or "None" for local development)
- **Organization Identifier**: `com.yourname` (or use `com.github-commit-tracker`)
- **Bundle Identifier**: Will be auto-generated (e.g., `com.yourname.GitHubCommitTracker`)
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: None (uncheck Core Data)
- **Include Tests**: Optional (can check if you want)

Click **Next** and save the project in:
```
/Users/shrey/Documents/Projects/GitHubCommitTracker
```

**IMPORTANT**: When saving, Xcode will ask if you want to create a new folder. Select "Don't Create" or "Use Existing Folder" since the directory already exists with our code.

## Step 3: Delete Default Files

Xcode will create some default files. Delete these:

1. In the Project Navigator (left sidebar), find and **delete** (Move to Trash):
   - `ContentView.swift` (if created)
   - Any default SwiftUI view files
   - Keep `Assets.xcassets` and the app file

## Step 4: Add Existing Source Files

Now add all our implemented files to the project:

1. Right-click on the `GitHubCommitTracker` folder in Project Navigator
2. Select **Add Files to "GitHubCommitTracker"...**
3. Navigate to `/Users/shrey/Documents/Projects/GitHubCommitTracker/GitHubCommitTracker/`
4. Select ALL folders:
   - `App/`
   - `Models/`
   - `Services/`
   - `ViewModels/`
   - `Views/`
   - `Utilities/`
5. Make sure these options are checked:
   - ✅ **Copy items if needed** (UNCHECKED - files are already in place)
   - ✅ **Create groups**
   - ✅ **Add to targets: GitHubCommitTracker**
6. Click **Add**

## Step 5: Configure Project Settings

### 5.1 General Settings

1. Select the **project** in Project Navigator (blue icon at top)
2. Select the **GitHubCommitTracker target**
3. Go to **General** tab:
   - **Deployment Target**: Set to **macOS 13.0** (Ventura) or later
   - **Category**: **Utilities**

### 5.2 Info.plist Configuration

1. Select the **GitHubCommitTracker target**
2. Go to **Info** tab
3. Add a new property (click the + button):
   - **Key**: `Application is agent (UIElement)`
   - **Type**: Boolean
   - **Value**: YES

   This makes the app a menubar-only app (won't appear in Dock or App Switcher).

4. Add another property:
   - **Key**: `LSUIElement`
   - **Type**: Boolean
   - **Value**: YES

   (This is an alternative way to specify the same thing)

### 5.3 Build Settings

1. Go to **Build Settings** tab
2. Search for "Swift Language Version"
3. Set to **Swift 6** (or Swift 5 if using older Xcode)

### 5.4 Signing & Capabilities

1. Go to **Signing & Capabilities** tab
2. **Automatically manage signing**: Check this
3. **Team**: Select your Apple Developer account (or leave as "None" for local testing)

Note: Keychain access will work without special entitlements for local development.

## Step 6: Update App Entry Point

The main app file might have been created by Xcode. Replace its contents:

1. Find the file that looks like `GitHubCommitTrackerApp.swift` in the root
2. Replace its contents with our implementation from:
   ```
   GitHubCommitTracker/App/GitHubCommitTrackerApp.swift
   ```

Or simply delete the Xcode-generated one and use ours.

## Step 7: Build and Run

1. Select **Product → Build** (or press `⌘B`)
2. Fix any build errors if they appear (usually import issues or typos)
3. Select **Product → Run** (or press `⌘R`)

The app should:
- Launch without showing a window
- Appear in the menubar (top-right, look for a chart icon)
- Click the icon to open the popover
- Show the settings/onboarding screen (first launch)

## Step 8: Create GitHub Personal Access Token

1. Click "Create Token" in the app
2. On GitHub, create a new token with scopes:
   - `read:user`
   - `repo`
3. Copy the token (starts with `ghp_`)
4. Paste it into the app and click "Connect"

## Troubleshooting

### Build Errors

If you get build errors:

1. **Missing modules**: Make sure all files are added to the target
   - Select each file in Project Navigator
   - Check "Target Membership" in File Inspector (right sidebar)
   - Ensure `GitHubCommitTracker` is checked

2. **Swift version mismatch**:
   - Go to Build Settings
   - Set Swift Language Version to Swift 5 or 6

3. **@Observable macro not found**:
   - Requires macOS 14+ or Swift 5.9+
   - If using older version, replace `@Observable` with `@ObservableObject` and add `@Published` to properties

### Runtime Issues

1. **App doesn't appear in menubar**:
   - Check `Info.plist` has `LSUIElement = YES`
   - Check console output for errors

2. **Keychain access denied**:
   - This shouldn't happen for local development
   - If it does, you may need to add Keychain entitlement

3. **Network requests fail**:
   - Check token is valid
   - Check internet connection
   - Check console for API error messages

## Alternative: Using Swift Package Manager (Advanced)

If you prefer not to use Xcode project, you can also create a `Package.swift` file for Swift Package Manager, but this is more complex for macOS apps with UI.

## Next Steps After Building

1. **Test the app**:
   - Token validation
   - Data fetching
   - Calendar display
   - Streak calculations
   - Month navigation
   - Refresh functionality

2. **Customize**:
   - Change menubar icon
   - Adjust colors in `Constants.swift`
   - Modify popover size
   - Add more statistics

3. **Distribute**:
   - Archive the app (Product → Archive)
   - Export as Mac App
   - Notarize for distribution (requires Apple Developer account)
   - Share with others!

## File Structure Reference

After setup, your project should look like:

```
GitHubCommitTracker/
├── GitHubCommitTracker.xcodeproj/
├── GitHubCommitTracker/
│   ├── App/
│   │   ├── GitHubCommitTrackerApp.swift
│   │   └── AppDelegate.swift
│   ├── Models/
│   │   ├── CommitData.swift
│   │   ├── GitHubModels.swift
│   │   └── StreakCalculator.swift
│   ├── Services/
│   │   ├── GitHubAPIService.swift
│   │   ├── KeychainService.swift
│   │   └── CacheManager.swift
│   ├── ViewModels/
│   │   ├── MenuBarViewModel.swift
│   │   └── SettingsViewModel.swift
│   ├── Views/
│   │   ├── MenuBarPopoverView.swift
│   │   ├── CalendarView.swift
│   │   ├── CalendarDayView.swift
│   │   ├── StreakDisplayView.swift
│   │   ├── SettingsView.swift
│   │   └── LoadingView.swift
│   └── Utilities/
│       ├── DateUtilities.swift
│       └── Constants.swift
└── Assets.xcassets/
```

## Support

If you encounter issues:
- Check the console output in Xcode for detailed error messages
- Verify all files are added to the target
- Ensure macOS deployment target is 13.0+
- Make sure you have a valid internet connection for API calls

Good luck building your GitHub Commit Tracker! 🚀
