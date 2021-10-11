//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker (iOS)
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
				.environmentObject(NavigationState.sharedInstance)
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
		LocationUtilities.locationManager.requestAlwaysAuthorization()
		LocationUtilities.locationManager.allowsBackgroundLocationUpdates = true
		LocationUtilities.locationManager.activityType = .automotiveNavigation
	}
	
}
