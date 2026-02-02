//
//  LoadingView.swift
//  GitHubCommitTracker
//
//  Loading spinner with message
//

import SwiftUI

struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.Colors.background.opacity(0.9))
    }
}

#Preview {
    LoadingView(message: "Loading commit data...")
        .frame(width: 300, height: 200)
}
