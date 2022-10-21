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
	
	@EnvironmentObject private var appStorageManager: AppStorageManager
	
	var body: some View {
		Form {
			Section {
				HStack {
					Text("\(self.appStorageManager.maximumStopDistance) meters")
					Spacer()
					Stepper("Maximum Stop Distance", value: self.appStorageManager.$maximumStopDistance, in: 1 ... 100)
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
					TextField("Server Base URL", value: self.appStorageManager.$baseURL, format: .compatibilityURL)
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
						self.appStorageManager.viewedAnnouncementIDs.removeAll()
						self.didResetViewedAnnouncements = true
					}
						.disabled(self.appStorageManager.viewedAnnouncementIDs.isEmpty)
					Button(
						"Reset Advanced Settings" + (self.didResetAdvancedSettings ? " ✓" : ""),
						role: .destructive
					) {
						self.appStorageManager.baseURL = AppStorageManager.Defaults.baseURL
						self.appStorageManager.maximumStopDistance = AppStorageManager.Defaults.maximumStopDistance
						self.didResetAdvancedSettings = true
					}
						.disabled(self.appStorageManager.baseURL == AppStorageManager.Defaults.baseURL && self.appStorageManager.maximumStopDistance == AppStorageManager.Defaults.maximumStopDistance)
						.onChange(of: self.appStorageManager.baseURL) { (_) in
							if self.appStorageManager.baseURL != AppStorageManager.Defaults.baseURL {
								self.didResetAdvancedSettings = false
							}
						}
						.onChange(of: self.appStorageManager.maximumStopDistance) { (_) in
							if self.appStorageManager.maximumStopDistance != AppStorageManager.Defaults.maximumStopDistance {
								self.didResetAdvancedSettings = false
							}
						}
				} else {
					Button("Reset Advanced Settings") {
						self.appStorageManager.baseURL = AppStorageManager.Defaults.baseURL
						self.appStorageManager.maximumStopDistance = AppStorageManager.Defaults.maximumStopDistance
					}
						.disabled(self.appStorageManager.baseURL == AppStorageManager.Defaults.baseURL && self.appStorageManager.maximumStopDistance == AppStorageManager.Defaults.maximumStopDistance)
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
