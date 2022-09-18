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
					EmptyView()
				}
				DynamicIslandExpandedRegion(.trailing) {
					EmptyView()
				}
				DynamicIslandExpandedRegion(.center) {
					EmptyView()
				}
				DynamicIslandExpandedRegion(.bottom) {
					EmptyView()
				}
			} compactLeading: {
				EmptyView()
			} compactTrailing: {
				EmptyView()
			} minimal: {
				EmptyView()
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
