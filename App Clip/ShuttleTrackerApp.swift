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
				.environmentObject(NavigationState.sharedInstance)
//				.appStoreOverlay(isPresented: self.$doShowAppStoreOverlay) { () -> SKOverlay.Configuration in
//					return SKOverlay.AppClipConfiguration(position: .bottomRaised)
//				}
		}
	}
	
	init() {
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
	}
	
}
