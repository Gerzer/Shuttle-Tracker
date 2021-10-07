//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import SwiftUI
import CoreLocation

@main struct ShuttleTrackerApp: App {
	
	private var contentView = ContentView()
	
	var body: some Scene {
		WindowGroup {
			self.contentView
				.environmentObject(MapState.sharedInstance)
		}
			.commands {
				CommandGroup(before: .sidebar) {
					Button("Refresh") {
						self.contentView.refreshBuses()
					}
						.keyboardShortcut(KeyEquivalent("r"), modifiers: .command)
				}
			}
	}
	
	init() {
		let coldLaunchCount = UserDefaults.standard.integer(forKey: DefaultsKeys.coldLaunchCount)
		UserDefaults.standard.set(coldLaunchCount + 1, forKey: DefaultsKeys.coldLaunchCount)
		LocationUtilities.locationManager = CLLocationManager()
		#if os(macOS)
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		#else // os(macOS)
		LocationUtilities.locationManager.requestAlwaysAuthorization()
		LocationUtilities.locationManager.allowsBackgroundLocationUpdates = true
		#endif // os(macOS)
		LocationUtilities.locationManager.activityType = .automotiveNavigation
	}
	
}
