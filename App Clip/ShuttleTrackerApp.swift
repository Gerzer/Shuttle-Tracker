//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker (App Clip)
//
//  Created by Gabriel Jacoby-Cooper on 9/30/20.
//

import SwiftUI
import StoreKit
import CoreLocation

@main struct ShuttleTrackerApp: App {
	
	@State private var doShowAppStoreOverlay = true
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(MapState.sharedInstance)
				.environmentObject(ViewState.sharedInstance)
//				.appStoreOverlay(isPresented: self.$doShowAppStoreOverlay) { () -> SKOverlay.Configuration in
//					return SKOverlay.AppClipConfiguration(position: .bottomRaised)
//				}
		}
	}
	
	init() {
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
		if #available(iOS 15, *) {
			Task(priority: .high) {
				try await UNUserNotificationCenter.current()
					.requestAuthorization(options: [.alert, .badge, .sound])
			}
		} else {
			UNUserNotificationCenter.current()
				.requestAuthorization(options: [.alert, .badge, .sound]) { (wasGranted, error) in
					if let error = error {
						LoggingUtilities.logger.log(level: .error, "\(error.localizedDescription)")
					}
					LoggingUtilities.logger.log(level: .info, "Notification permission \(wasGranted ? "was" : "wasn't") granted")
				}
		}
		let longTripCategory = UNNotificationCategory(
			identifier: NotificationUtilities.Constants.longTripCategoryIdentifier,
			actions: [
				UNNotificationAction(
					identifier: NotificationUtilities.Constants.leaveBusActionIdentifier,
					title: "Leave Bus",
					options: []
				)
			],
			intentIdentifiers: [],
			options: []
		)
		UNUserNotificationCenter.current()
			.setNotificationCategories([longTripCategory])
		UNUserNotificationCenter.current()
			.delegate = NotificationUtilities.userNotificationCenterDelegate
	}
	
}
