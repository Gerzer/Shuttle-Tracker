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
        var submissionStatus : Bool
        var code : String
		var status : String
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
                if context.state.submissionStatus == true {
                    Text("The location submission succeeded.")
                        .foregroundColor(.green)
                }
                else {
                    Text("The location submission failed.")
                        .foregroundColor(.red)
                }
                Text("HTTP \(context.state.code): \(context.state.status)")
                    .monospaced()
                }
				.activitySystemActionForegroundColor(Color.black)
                .padding()
			
		} dynamicIsland: { (context) in
			DynamicIsland {
				// Expanded UI goes here.  Compose the expanded UI through
				// various regions, like leading/trailing/center/bottom
				DynamicIslandExpandedRegion(.leading) {
                    if context.state.submissionStatus == true {
                        Text("Submission succeeded.")
                            .foregroundColor(.green)
                    }
                    else {
                        Text("Submission failed.")
                            .foregroundColor(.red)
                    }
				}
				DynamicIslandExpandedRegion(.trailing) {
                    Text("Bus \(context.attributes.busID)")
                        .bold()
				}
				DynamicIslandExpandedRegion(.bottom) {
                    Text("HTTP \(context.state.code): \(context.state.status)")
                        .monospaced()
				}
			} compactLeading: {
                Image(systemName: "bus.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundColor(.red)
                
			} compactTrailing: {
                if context.state.submissionStatus {
                    Image(systemName: "checkmark.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundColor(.green)
                }
                else {
                    Image(systemName: "xmark.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundColor(.red)
                }
			} minimal: {
                HStack {
                    if context.state.submissionStatus {
                        Image(systemName: "checkmark.circle")
                            .symbolRenderingMode(.palette)
                            .foregroundColor(.green)
                    }
                    else {
                        Image(systemName: "xmark.circle")
                            .symbolRenderingMode(.palette)
                            .foregroundColor(.red)
                    }
                }
			}
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
