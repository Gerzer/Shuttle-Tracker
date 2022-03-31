//
//  InfoSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Andrew Emanuel on 10/5/21.
//

import SwiftUI

struct InfoSheet: View {
	
	@State private var schedule: Schedule?
	
	var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading, spacing: 0) {
					Text("Shuttle Tracker shows you the real-time locations of the RPI campus shuttles, powered by crowd-sourced location data.")
						.padding(.bottom)
					Section {
						VStack(alignment: .leading, spacing: 0) {
							if let schedule = self.schedule {
								let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
								let times = [schedule.content.monday, schedule.content.tuesday, schedule.content.wednesday, schedule.content.thursday, schedule.content.friday, schedule.content.saturday, schedule.content.sunday]
								ForEach(0 ..< 7) { (index) in
									Text("\(days[index]): \(times[index].start) to \(times[index].end)")
								}
							} else {
								Text("Monday through Friday: 7:00 AM to 11:45 PM")
								Text("Saturday: 9:00 AM to 11:45 PM")
								Text("Sunday: 9:00 AM to 8:00 PM")
							}
							
						}
							.padding(.bottom)
					} header: {
						Text("Schedule")
							.font(.headline)
					}
					Section {
						Text("The map is automatically refreshed every 5 seconds. Green buses have high-quality location data, and red buses have low-quality location data. When boarding a bus, tap “Board Bus”, and when getting off, tap “Leave Bus”. You must be within 20 meters of a stop to board a bus.")
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
				.navigationTitle("About")
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
