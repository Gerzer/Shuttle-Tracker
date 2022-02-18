//
//  InfoSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Andrew Emanuel on 10/5/21.
//

import SwiftUI

struct InfoSheet: View {

	var body: some View {
		NavigationView {
            
            // Display info sheet with scroll gradient for iOS 15 or newer (not supported on older versions)
            
            if #available(iOS 15.0, *) {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Shuttle Tracker shows you the real-time locations of the RPI campus shuttles, powered by crowd-sourced location data.")
                            .padding(.bottom)
                    Group {
                        Text("Schedule")
                            .font(.headline)
                        Text("Monday through Friday: 7:00 AM to 11:45 PM")
                        Text("Saturday: 9:00 AM to 11:45 PM")
                        Text("Sunday: 9:00 AM to 8:00 PM")
                            .padding(.bottom)
                        Text("Instructions")
                            .font(.headline)
                    }
                        Text("The map is automatically refreshed every 5 seconds. Green buses have high-quality location data, and red buses have low-quality location data. When boarding a bus, tap “Board Bus”, and when getting off, tap “Leave Bus”. You must be within 20 meters of a stop to board a bus.")
                            .padding(.bottom)
                        Text("Privacy")
                            .font(.headline)
                        Text("Shuttle Tracker sends your location data to our server only when you tap “Board Bus” and stops sending these data when you tap “Leave Bus”. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, or any other identifying information. We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates.")
                    }
                }
                
                // Bottom fade effect/mask
                .mask(alignment: .bottom) {
                    VStack(spacing: 0) {
                        LinearGradient(
                              stops: [
                                Gradient.Stop(color: .clear, location: .zero),
                                Gradient.Stop(color: .black, location: 1.0)
                              ],
                              startPoint: .top,
                              endPoint: .bottom
                            )
                            .frame(height: 64)
                        Color.black
                    }
                    .rotationEffect(Angle(degrees: 180)) // to make mask on bottom
                }
                
                // Top fade effect/mask
                .mask(alignment: .top) {
                    VStack(spacing: 0) {
                        LinearGradient(
                              stops: [
                                Gradient.Stop(color: .clear, location: .zero),
                                Gradient.Stop(color: .black, location: 1.0)
                              ],
                              startPoint: .top,
                              endPoint: .bottom
                            )
                            .frame(height: 64)
                        Color.black
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Shuttle Tracker 🚐")
                .toolbar {
                    ToolbarItem {
                        CloseButton()
                    }
                }
            } else {
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
                        Text("The map is automatically refreshed every 5 seconds. Green buses have high-quality location data, and red buses have low-quality location data. When boarding a bus, tap “Board Bus”, and when getting off, tap “Leave Bus”. You must be within 20 meters of a stop to board a bus.")
                            .padding(.bottom)
                        Text("Privacy")
                            .font(.headline)
                        Text("Shuttle Tracker sends your location data to our server only when you tap “Board Bus” and stops sending these data when you tap “Leave Bus”. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, or any other identifying information. We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates.")
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Shuttle Tracker 🚐")
                .toolbar {
                    ToolbarItem {
                        CloseButton()
                    }
                }
            }
		}
	}
}

struct InfoSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		InfoSheet()
	}
	
}
