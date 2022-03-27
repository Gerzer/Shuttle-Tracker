//
//  InfoView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Andrew Emanuel on 10/5/21.
//

import SwiftUI

struct InfoView: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	@AppStorage("MaximumStopDistance") private var maximumStopDistance = 50
	
	var body: some View {
		SheetPresentationWrapper {
			ScrollView {
				VStack(alignment: .leading) {
					Text("Shuttle Tracker shows you the real-time locations of the RPI campus shuttles, powered by crowd-sourced location data.")
						.padding(.bottom)
					Text("Schedule")
						.font(.headline)
					Text("Monday through Friday: 7:00 AM to 11:45 PM")
					Text("Saturday: 9:00 AM to 11:45 PM")
					Text("Sunday: 9:00 AM to 8:00 PM")
						.padding(.bottom)
					Text("Instructions")
						.font(.headline)
					Text("The map is automatically refreshed every 5 seconds. Green buses have high-quality location data, and red buses have low-quality location data. When boarding a bus, tap “Board Bus”, and when getting off, tap “Leave Bus”. You must be within \(self.maximumStopDistance) meter\(self.maximumStopDistance == 1 ? "" : "s") of a stop to board a bus.")
						.padding(.bottom)
					Text("Privacy")
						.font(.headline)
					Text("Shuttle Tracker sends your location data to our server only when you tap “Board Bus” and stops sending these data when you tap “Leave Bus”. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, or any other identifying information. We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates.")
					Button {
						self.sheetStack.push(.whatsNew)
					} label: {
						Text("See What’s New")
							.bold()
					}
						.buttonStyle(.block)
						.padding(.vertical)
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
	}
	
}

struct InfoViewPreviews: PreviewProvider {
	
	static var previews: some View {
		InfoView()
			.environmentObject(ViewState.shared)
	}
	
}
