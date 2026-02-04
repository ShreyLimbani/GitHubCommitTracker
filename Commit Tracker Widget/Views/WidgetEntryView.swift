//
//  WidgetEntryView.swift
//  CommitTrackerWidget
//
//  Main widget entry view - routes to appropriate size view
//

import SwiftUI
import WidgetKit

struct WidgetEntryView: View {
    var entry: CommitTrackerEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

#Preview(as: .systemSmall) {
    CommitTrackerWidget()
} timeline: {
    CommitTrackerEntry.placeholder
}
