# Project Structure

This document outlines the folder structure for the GitHub Commit Tracker macOS app.

## Directory Layout

```
GitHubCommitTracker/
├── GitHubCommitTracker.xcodeproj/      # Xcode project (to be created)
├── GitHubCommitTracker/
│   ├── App/
│   │   ├── GitHubCommitTrackerApp.swift          # Main app entry
│   │   ├── AppDelegate.swift                     # MenuBar management
│   │   └── Info.plist
│   ├── Models/
│   │   ├── GitHubModels.swift                    # API response models
│   │   ├── CommitData.swift                      # Core data structures
│   │   ├── StreakCalculator.swift                # Streak calculation logic
│   │   └── UserSettings.swift
│   ├── Services/
│   │   ├── GitHubAPIService.swift                # GitHub GraphQL client
│   │   ├── KeychainService.swift                 # Secure token storage
│   │   ├── CacheManager.swift                    # Local data caching
│   │   └── CommitDataManager.swift               # Data coordinator
│   ├── ViewModels/
│   │   ├── MenuBarViewModel.swift                # Main state management
│   │   ├── CalendarViewModel.swift
│   │   └── SettingsViewModel.swift
│   ├── Views/
│   │   ├── MenuBarPopoverView.swift              # Main popover (320x440px)
│   │   ├── CalendarView.swift                    # Calendar grid
│   │   ├── CalendarDayView.swift                 # Individual day cells
│   │   ├── StreakDisplayView.swift               # Statistics panel
│   │   ├── SettingsView.swift                    # Token setup UI
│   │   └── LoadingView.swift
│   ├── Utilities/
│   │   ├── DateUtilities.swift
│   │   ├── Constants.swift
│   │   └── Extensions/
│   └── Resources/
└── Tests/
```

## Next Steps

1. Create Xcode project
2. Configure as MenuBar-only app (LSUIElement = true)
3. Set minimum deployment target to macOS 13.0
4. Begin implementing core components following the plan

## Implementation Order

1. **Phase 1**: Project setup & menubar infrastructure
2. **Phase 2**: GitHub API integration
3. **Phase 3**: Streak calculation logic
4. **Phase 4**: UI implementation
5. **Phase 5**: Caching & state management
6. **Phase 6**: Testing & polish

See [squishy-prancing-parnas.md](../squishy-prancing-parnas.md) for detailed implementation plan.
