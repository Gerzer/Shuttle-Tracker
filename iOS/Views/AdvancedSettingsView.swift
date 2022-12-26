//
//  AdvancedSettingsView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 1/23/22.
//

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
			if #available(iOS 16, *) { // All Debug Mode functionality requires iOS 16, so we shouldn’t show the toggle on older OSes
				Section {
					Toggle("Debug Mode", isOn: self.appStorageManager.$debugMode)
				} footer: {
					Text("Shows information that’s useful for debugging Board Bus functionality.")
				}
			}
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
					self.appStorageManager.debugMode = AppStorageManager.Defaults.debugMode
					self.appStorageManager.maximumStopDistance = AppStorageManager.Defaults.maximumStopDistance
					self.appStorageManager.baseURL = AppStorageManager.Defaults.baseURL
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
					.disabled(self.appStorageManager.debugMode == AppStorageManager.Defaults.debugMode && self.appStorageManager.maximumStopDistance == AppStorageManager.Defaults.maximumStopDistance && self.appStorageManager.baseURL == AppStorageManager.Defaults.baseURL)
					.onChange(of: self.appStorageManager.debugMode) { (_) in
						if self.appStorageManager.debugMode != AppStorageManager.Defaults.debugMode {
							self.didResetAdvancedSettings = false
						}
					}
					.onChange(of: self.appStorageManager.maximumStopDistance) { (_) in
						if self.appStorageManager.maximumStopDistance != AppStorageManager.Defaults.maximumStopDistance {
							self.didResetAdvancedSettings = false
						}
					}
					.onChange(of: self.appStorageManager.baseURL) { (_) in
						if self.appStorageManager.baseURL != AppStorageManager.Defaults.baseURL {
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
