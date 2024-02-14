//
//  AdvancedSettingsView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 1/23/22.
//

import STLogging
import SwiftUI

struct AdvancedSettingsView: View {
	
	@State
	private var didResetViewedAnnouncements = false
	
	@State
	private var didResetAdvancedSettings = false
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
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
			Section {
				Button(role: .destructive) {
					Task {
						do {
							try await UNUserNotificationCenter.updateBadge()
						} catch {
							#log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Failed to update badge: \(error, privacy: .public)")
						}
					}
					withAnimation {
						self.appStorageManager.viewedAnnouncementIDs.removeAll()
						self.didResetViewedAnnouncements = true
					}
				} label: {
					HStack {
						Text("Reset Viewed Announcements")
						if self.didResetViewedAnnouncements {
							Spacer()
							Text("✓")
						}
					}
				}
					.disabled(self.appStorageManager.viewedAnnouncementIDs.isEmpty)
				Button(role: .destructive) {
					self.appStorageManager.baseURL = AppStorageManager.Defaults.baseURL
					self.appStorageManager.maximumStopDistance = AppStorageManager.Defaults.maximumStopDistance
					withAnimation {
						self.didResetAdvancedSettings = true
					}
				} label: {
					HStack {
						Text("Reset Advanced Settings")
						if self.didResetAdvancedSettings {
							Spacer()
							Text("✓")
						}
					}
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
			.environmentObject(AppStorageManager.shared)
	}
	
}
