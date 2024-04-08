//
//  AdvancedSettingsView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 1/23/22.
//

import STLogging
import SwiftUI

@available(iOS 17, *)
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
					Text("^[\(self.appStorageManager.maximumStopDistance) meter](inflect: true)")
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
				HStack {
					Text("^[\(self.appStorageManager.routeTolerance) meter](inflect: true)")
					Spacer()
					Stepper("Route Tolerance", value: self.appStorageManager.$routeTolerance, in: 1 ... 50)
						.labelsHidden()
				}
			} header: {
				Text("Route Tolerance")
			} footer: {
				Text("The distance in meters from a route at which Board Bus is automatically deactivated.")
			}
			Section {
                if #available(iOS 16, *) { // All Debug Mode functionality requires iOS 16, so we shouldn’t show the toggle on older OSes
                    Section {
                        Toggle("Debug Mode", isOn: self.appStorageManager.$debugMode)
                    } footer: {
                        Text("Shows information that’s useful for debugging Board Bus functionality.")
                    }
                }
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
					self.appStorageManager.debugMode = AppStorageManager.Defaults.debugMode
					self.appStorageManager.maximumStopDistance = AppStorageManager.Defaults.maximumStopDistance
					self.appStorageManager.baseURL = AppStorageManager.Defaults.baseURL
					self.appStorageManager.routeTolerance = AppStorageManager.Defaults.routeTolerance
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
					.onChange(of: self.appStorageManager.baseURL) {
						if self.appStorageManager.baseURL != AppStorageManager.Defaults.baseURL {
							self.didResetAdvancedSettings = false
						}
					}
					.onChange(of: self.appStorageManager.maximumStopDistance) {
						if self.appStorageManager.maximumStopDistance != AppStorageManager.Defaults.maximumStopDistance {
							self.didResetAdvancedSettings = false
						}
					}
					.onChange(of: self.appStorageManager.routeTolerance) {
						if self.appStorageManager.routeTolerance != AppStorageManager.Defaults.routeTolerance {
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

@available(iOS 17, *)
#Preview {
	AdvancedSettingsView()
		.environmentObject(AppStorageManager.shared)
}
