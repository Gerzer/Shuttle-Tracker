//
//  LiveActivity.swift
//  Live Activity
//
//  Created by Gabriel Jacoby-Cooper on 1/27/23.
//

import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct DebugModeActivityAttributes: ActivityAttributes {
	
	public struct ContentState: Codable, Hashable {
		// Dynamic stateful properties about your activity go here!
		var status: String
	}
	// Fixed non-changing properties about your activity go here!
	var busID: Int
}

@available(iOS 16.1, *)
struct LiveActivity: Widget {
	
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: DebugModeActivityAttributes.self) { (context) in
			// Lock screen/banner UI goes here
            VStack(alignment: .leading) {
                HStack {
                    Text("Shuttle Tracker")
                        .font(.headline)
                        .bold()
                    Spacer()
                    VStack{
                        Image(systemName: "bus.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                    }
                }

                HStack {
                    Text("A location was submitted... ")
                        .bold()
                    Spacer()
                    Text("Bus \(context.attributes.busID)")
                        .bold()
                }
                
                Text("the location submission failed.")
                    .foregroundColor(.red)
                
                Text("HTTP 409 Conflict")
                    .monospaced()
                
                ProgressView(timerInterval: .now ... .now + 3) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                    }

                }
            .activityBackgroundTint(.white.opacity(0.8))
				.activitySystemActionForegroundColor(Color.black)
                .padding()
			
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

@available(iOS 16.1, *)
struct LockScreenLiveActivityView : View {
    
    let context : ActivityViewContext<DebugModeActivityAttributes>
    
    var body: some View {
        VStack {
            Spacer()
            Text(context.state.status)
            Spacer()
        }
    }
}

//@available(iOS 16.1, *)
//struct LiveActivityPreviews: PreviewProvider {
//	
//    static let attributes = DebugModeActivityAttributes(busID: 90)
//	
//	static let contentState = DebugModeActivityAttributes.ContentState(status: "Text")
//	
//	static var previews: some View {
//		self.attributes
//			.previewContext(self.contentState, viewKind: .dynamicIsland(.compact))
//			.previewDisplayName("Island Compact")
//		self.attributes
//			.previewContext(self.contentState, viewKind: .dynamicIsland(.expanded))
//			.previewDisplayName("Island Expanded")
//		self.attributes
//			.previewContext(self.contentState, viewKind: .dynamicIsland(.minimal))
//			.previewDisplayName("Minimal")
//		self.attributes
//			.previewContext(self.contentState, viewKind: .content)
//			.previewDisplayName("Notification")
//	}
//	
//}
