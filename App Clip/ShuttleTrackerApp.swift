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
	
	@ObservedObject private var mapState = MapState.shared
	
	@ObservedObject private var viewState = ViewState.shared
	
	@ObservedObject private var sheetStack = SheetStack.shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(self.mapState)
				.environmentObject(self.viewState)
				.environmentObject(self.sheetStack)
				.onAppear {
					let overlay = SKOverlay(
						configuration: SKOverlay.AppClipConfiguration(position: .bottom)
					)
					for scene in UIApplication.shared.connectedScenes {
						guard let windowScene = scene as? UIWindowScene else {
							continue
						}
						overlay.present(in: windowScene)
					}
				}
		}
	}
	
	init() {
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
		LocationUtilities.locationManager.showsBackgroundLocationIndicator = true
	}
	
}
