//
//  AdvancedSettingsView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 1/23/22.
//

import SwiftUI

struct AdvancedSettingsView: View {
	
	@State private var didResetViewedAnnouncements = false
	
	@State private var didResetAdvancedSettings = false
	
	@AppStorage("BaseURL") private var baseURL = Self.defaultBaseURL
	
	@AppStorage("MaximumStopDistance") private var maximumStopDistance = Self.defaultMaximumStopDistance
	
	@AppStorage("ViewedAnnouncementIDs") private var viewedAnnouncementIDs: Set<UUID> = []
	
	private static let defaultBaseURL = URL(string: "https://shuttletracker.app")!
	
	private static let defaultMaximumStopDistance = 50
	
	var body: some View {
		Form {
			Section {
				HStack {
					Text("\(self.maximumStopDistance) meters")
					Spacer()
					Stepper("Maximum Stop Distance", value: self.$maximumStopDistance, in: 1 ... 100)
						.labelsHidden()
				}
			} header: {
				Text("Maximum Stop Distance")
			} footer: {
				Text("The maximum distance in meters from the nearest stop at which you can board a bus.")
			}
			if #available(iOS 15, *) {
				Section {
					// URL.FormatStyle’s integration with TextField seems to be broken currently, so we fall back on our custom URL format style
					TextField("Server Base URL", value: self.$baseURL, format: .compatibilityURL)
						.labelsHidden()
						.keyboardType(.url)
				} header: {
					Text("Server Base URL")
				} footer: {
					Text("The base URL for the API server. Changing this setting could make the rest of the app stop working properly.")
				}
			}
			Section {
				if #available(iOS 15, *) {
					Button(
						"Reset Viewed Announcements" + (self.didResetViewedAnnouncements ? " ✓" : ""),
						role: .destructive
					) {
						self.viewedAnnouncementIDs.removeAll()
						self.didResetViewedAnnouncements = true
					}
						.disabled(self.viewedAnnouncementIDs.isEmpty)
					Button(
						"Reset Advanced Settings" + (self.didResetAdvancedSettings ? " ✓" : ""),
						role: .destructive
					) {
						self.baseURL = URL(string: "https://shuttletracker.app")!
						self.maximumStopDistance = 50
						self.didResetAdvancedSettings = true
					}
						.disabled(self.baseURL == Self.defaultBaseURL && self.maximumStopDistance == Self.defaultMaximumStopDistance)
				} else {
					Button("Reset Advanced Settings") {
						self.baseURL = URL(string: "https://shuttletracker.app")!
						self.maximumStopDistance = 50
					}
						.disabled(self.baseURL == Self.defaultBaseURL && self.maximumStopDistance == Self.defaultMaximumStopDistance)
				}
			}
		}
			.navigationTitle("Advanced")
			.toolbar {
				ToolbarItem {
					CloseButton()
				}
			}
	}
	
}

struct AdvancedSettingsViewPreviews: PreviewProvider {
	
	static var previews: some View {
		AdvancedSettingsView()
	}
	
}
