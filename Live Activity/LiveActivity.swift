//
//  LiveActivity.swift
//  Live Activity
//
//  Created by Gabriel Jacoby-Cooper on 1/27/23.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct LiveActivityAttributes: ActivityAttributes {
	
	public struct ContentState: Codable, Hashable {
		// Dynamic stateful properties about your activity go here!
		var status: String
	}
	// Fixed non-changing properties about your activity go here!
	var name: String
	
}

struct LiveActivity: Widget {
	
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: LiveActivityAttributes.self) { (context) in
			// Lock screen/banner UI goes here
			HStack {
                Text("Type of debugging " + context.attributes.name)
			}
				.activityBackgroundTint(Color.cyan)
				.activitySystemActionForegroundColor(Color.black)
			
		} dynamicIsland: { (context) in
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
					Text("Bottom")
					// more content
				}
			} compactLeading: {
				Text("L")
			} compactTrailing: {
				Text("T")
			} minimal: {
				Text("Min")
			}
				.widgetURL(URL(string: "http://www.apple.com"))
				.keylineTint(Color.red)
		}
	}
}

struct LockScreenLiveActivityView : View {
    
    let context : ActivityViewContext<LiveActivityAttributes>
    
    var body: some View {
        VStack {
            Spacer()
            Text(context.state.status)
            Spacer()
        }
    }
}

struct LiveActivityPreviews: PreviewProvider {
	
	static let attributes = LiveActivityAttributes(name: "Me")
	
	static let contentState = LiveActivityAttributes.ContentState(status: "Text")
	
	static var previews: some View {
		self.attributes
			.previewContext(self.contentState, viewKind: .dynamicIsland(.compact))
			.previewDisplayName("Island Compact")
		self.attributes
			.previewContext(self.contentState, viewKind: .dynamicIsland(.expanded))
			.previewDisplayName("Island Expanded")
		self.attributes
			.previewContext(self.contentState, viewKind: .dynamicIsland(.minimal))
			.previewDisplayName("Minimal")
		self.attributes
			.previewContext(self.contentState, viewKind: .content)
			.previewDisplayName("Notification")
	}
	
}
