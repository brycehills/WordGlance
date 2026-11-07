//
//  WordGlanceWidgetLiveActivity.swift
//  WordGlanceWidget
//
//  Created by Bryce Hills on 11/6/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WordGlanceWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WordGlanceWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WordGlanceWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WordGlanceWidgetAttributes {
    fileprivate static var preview: WordGlanceWidgetAttributes {
        WordGlanceWidgetAttributes(name: "World")
    }
}

extension WordGlanceWidgetAttributes.ContentState {
    fileprivate static var smiley: WordGlanceWidgetAttributes.ContentState {
        WordGlanceWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WordGlanceWidgetAttributes.ContentState {
         WordGlanceWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WordGlanceWidgetAttributes.preview) {
   WordGlanceWidgetLiveActivity()
} contentStates: {
    WordGlanceWidgetAttributes.ContentState.smiley
    WordGlanceWidgetAttributes.ContentState.starEyes
}
