//
//  CommitTrackerWidget.swift
//  CommitTrackerWidget
//
//  Widget definition and bundle entry point
//

import WidgetKit
import SwiftUI

@main
struct CommitTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        CommitTrackerWidget()
    }
}

struct CommitTrackerWidget: Widget {
    let kind: String = "CommitTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CommitTrackerProvider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("GitHub Commits")
        .description("Track your GitHub commit activity and streaks on your desktop.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
