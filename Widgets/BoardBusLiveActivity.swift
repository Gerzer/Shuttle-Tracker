//
//  BoardBusLiveActivity.swift
//  Widgets
//
//  Created by Gabriel Jacoby-Cooper on 9/17/22.
//

//import Intents
import MapKit
import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct BoardBusLiveActivity: Widget {
	
	let kind: String = "BoardBusLiveActivity"
	
//	var body: some WidgetConfiguration {
//		IntentConfiguration(
//			kind: self.kind,
//			intent: ConfigurationIntent.self,
//			provider: Provider()
//		) { (entry) in
//			LiveActivityEntryView(entry: entry)
//		}
//		.configurationDisplayName("Shuttle Tracker")
//		.description("This is an example widget.")
//	}
	
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: BoardBusAttributes.self) { (context) in
//			MapView(
//				stops: context.attributes.stops,
//				routes: context.attributes.routes,
//				travelState: Binding {
//					return context.state.travelState
//				} set: { (newValue) in
//					fatalError()
//				}
//			)
			switch context.state.travelState {
			case .onBus:
				Text("You’re on a bus!")
			case .notOnBus:
				Text("You’re not on a bus.")
			}
		} dynamicIsland: { (context) in
			return DynamicIsland {
				DynamicIslandExpandedRegion(.leading) {
					Text("🚐")
				}
				DynamicIslandExpandedRegion(.trailing) {
					Text("🚐")
				}
				DynamicIslandExpandedRegion(.center) {
					switch context.state.travelState {
					case .onBus:
						Text("You’re on a bus!")
					case .notOnBus:
						Text("You’re not on a bus.")
					}
				}
				DynamicIslandExpandedRegion(.bottom) {
					Text("🚐")
				}
			} compactLeading: {
				Text("🚐")
			} compactTrailing: {
				Text("🚐")
			} minimal: {
				Text("🚐")
			}
		}
	}
	
}

//struct LiveActivityPreviews: PreviewProvider {
//
//	static var previews: some View {
//		LiveActivityEntryView(
//			entry: SimpleEntry(
//				date: Date(),
//				configuration: ConfigurationIntent()
//			)
//		)
//		.previewContext(WidgetPreviewContext(family: .systemSmall))
//	}
//
//}

//struct Provider: IntentTimelineProvider {
//
//	func placeholder(in context: Context) -> SimpleEntry {
//		return SimpleEntry(date: Date(), configuration: ConfigurationIntent())
//	}
//
//	func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//		let entry = SimpleEntry(date: Date(), configuration: configuration)
//		completion(entry)
//	}
//
//	func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//		var entries: [SimpleEntry] = []
//
//		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
//		let currentDate = Date()
//		for hourOffset in 0 ..< 5 {
//			let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//			let entry = SimpleEntry(date: entryDate, configuration: configuration)
//			entries.append(entry)
//		}
//
//		let timeline = Timeline(entries: entries, policy: .atEnd)
//		completion(timeline)
//	}
//
//}

//struct SimpleEntry: TimelineEntry {
//
//	let date: Date
//
//	let configuration: ConfigurationIntent
//
//}

//struct LiveActivityEntryView : View {
//
//	var entry: Provider.Entry
//
//	var body: some View {
//		Text(self.entry.date, style: .time)
//	}
//
//}

@available(iOSApplicationExtension 16.1, *)
struct LockScreenView: View {
    var context: ActivityViewContext<BoardBusAttributes>
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .center) {
//                    Text(context.state.courierName + " is on the way!").font(.headline)
//                    Text("You ordered \(context.attributes.numberOfGroceyItems) grocery items.")
//                        .font(.subheadline)
//                    BottomLineView(time: context.state.deliveryTime)
                }
            }
        }.padding(15)
    }
}

struct BottomLineView: View {
    var time: Date
    var body: some View {
        HStack {
            /*
             Divider().frame(width: 50,
                             height: 10)
             .overlay(.gray).cornerRadius(5)
             */
            Image("delivery")
            VStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 1,
                                               dash: [4]))
                    .frame(height: 20)
                    .overlay(Text(time, style: .timer).font(.system(size: 8)).multilineTextAlignment(.center))
            }
            Image("home-address")
        }
    }
}
