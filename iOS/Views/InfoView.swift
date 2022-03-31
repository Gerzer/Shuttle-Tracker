//
//  InfoView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 3/4/22.
//

import SwiftUI

struct InfoView: View {
	
	@State private var schedule: Schedule?
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	@AppStorage("MaximumStopDistance") private var maximumStopDistance = 50
	
	var body: some View {
		SheetPresentationWrapper {
			ScrollView {
				VStack(alignment: .leading, spacing: 0) {
					Text("Shuttle Tracker shows you the real-time locations of the RPI campus shuttles, powered by crowd-sourced location data.")
						.padding(.bottom)
					if let schedule = self.schedule {
						Section {
							HStack {
								VStack(alignment: .leading, spacing: 0) {
									Text("Monday")
									Text("Tuesday")
									Text("Wednesday")
									Text("Thursday")
									Text("Friday")
									Text("Saturday")
									Text("Sunday")
								}
								VStack(alignment: .leading, spacing: 0) {
									Text("\(schedule.content.monday.start) to \(schedule.content.monday.end)")
									Text("\(schedule.content.tuesday.start) to \(schedule.content.tuesday.end)")
									Text("\(schedule.content.wednesday.start) to \(schedule.content.wednesday.end)")
									Text("\(schedule.content.thursday.start) to \(schedule.content.thursday.end)")
									Text("\(schedule.content.friday.start) to \(schedule.content.friday.end)")
									Text("\(schedule.content.saturday.start) to \(schedule.content.saturday.end)")
									Text("\(schedule.content.sunday.start) to \(schedule.content.sunday.end)")
								}
								Spacer()
							}
								.padding(.bottom)
						} header: {
							Text("Schedule")
								.font(.headline)
						}
					}
					Section {
						Text("The map is automatically refreshed every 5 seconds. Green buses have high-quality location data, and red buses have low-quality location data. When boarding a bus, tap “Board Bus”, and when getting off, tap “Leave Bus”. You must be within \(self.maximumStopDistance) meter\(self.maximumStopDistance == 1 ? "" : "s") of a stop to board a bus.")
							.padding(.bottom)
					} header: {
						Text("Instructions")
							.font(.headline)
					}
					Section {
						Text("Shuttle Tracker sends your location data to our server only when you tap “Board Bus” and stops sending these data when you tap “Leave Bus”. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, or any other identifying information. We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates.")
							.padding(.bottom)
					} header: {
						Text("Privacy")
							.font(.headline)
					}
				}
				.padding(.horizontal)
			}
				.navigationTitle("Shuttle Tracker 🚐")
				.toolbar {
					ToolbarItem {
						CloseButton()
					}
				}
		}
			.onAppear {
				if #available(iOS 15, *) {
					Task {
						self.schedule = await Schedule.download()
					}
				}
			}
	}
	
}

struct InfoViewPreviews: PreviewProvider {
	
	static var previews: some View {
		InfoView()
			.environmentObject(ViewState.shared)
	}
	
}
