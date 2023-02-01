//
//  LiveActivity.swift
//  Live Activity
//
//  Created by Gabriel Jacoby-Cooper on 1/27/23.
//

import ActivityKit
import SwiftUI
import WidgetKit
import CoreLocation

struct LiveActivityAttributes: ActivityAttributes {
	public struct ContentState: Codable, Hashable {
        var latitude: CLLocationDegrees
        
        var longitude: CLLocationDegrees
        
        var timestamp: Date
	}
	
	var message: String
}

@available(iOS 16.1, *)
struct LiveActivity: Widget {
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: LiveActivityAttributes.self) { (context) in
			// Lock screen/banner UI goes here
			VStack {
                Text(context.attributes.message + " (\(context.state.latitude), \(context.state.longitude)) at \(context.state.timestamp)")
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

@available(iOS 16.2, *)
struct LiveActivityPreviews: PreviewProvider {
	
    static let attributes = LiveActivityAttributes(message: "Temp")
	
    static let contentState = LiveActivityAttributes.ContentState(latitude: 0, longitude: 0, timestamp: .now)
	
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
