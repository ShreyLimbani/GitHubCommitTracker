//
//  AppearanceSection.swift
//  GitHubCommitTracker
//
//  Appearance mode selection (Light/Dark/System)
//

import SwiftUI

struct AppearanceSection: View {
    let viewModel: EnhancedSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text("Appearance")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.7))

            // Appearance mode picker
            HStack(spacing: 0) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    AppearanceButton(
                        mode: mode,
                        isSelected: viewModel.currentAppearance == mode,
                        onTap: {
                            viewModel.setAppearance(mode)
                        }
                    )
                }
            }
            .background(Constants.Colors.secondaryBackground)
            .cornerRadius(8)
        }
    }
}

struct AppearanceButton: View {
    let mode: AppearanceMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 12))

                Text(mode.displayName)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        switch mode {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "laptopcomputer"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AppearanceSection(
            viewModel: EnhancedSettingsViewModel(
                mainViewModel: MenuBarViewModel()
            )
        )
    }
    .frame(width: Constants.UI.popoverWidth)
    .padding()
}
