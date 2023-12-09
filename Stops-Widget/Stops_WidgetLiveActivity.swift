//
//  Stops_WidgetLiveActivity.swift
//  Stops-Widget
//
//  Created by Yi Chen on 12/8/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Stops_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Stops_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Stops_WidgetAttributes.self) { context in
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

extension Stops_WidgetAttributes {
    fileprivate static var preview: Stops_WidgetAttributes {
        Stops_WidgetAttributes(name: "World")
    }
}

extension Stops_WidgetAttributes.ContentState {
    fileprivate static var smiley: Stops_WidgetAttributes.ContentState {
        Stops_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Stops_WidgetAttributes.ContentState {
         Stops_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Stops_WidgetAttributes.preview) {
   Stops_WidgetLiveActivity()
} contentStates: {
    Stops_WidgetAttributes.ContentState.smiley
    Stops_WidgetAttributes.ContentState.starEyes
}
