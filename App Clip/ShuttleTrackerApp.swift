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
	
	private static let sheetStack = SheetStack()
	
	@ObservedObject private var mapState = MapState.shared
	
	@ObservedObject private var viewState = ViewState.shared
	
	@ObservedObject private var appStorageManager = AppStorageManager.shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(self.mapState)
				.environmentObject(self.viewState)
				.environmentObject(self.appStorageManager)
				.environmentObject(Self.sheetStack)
				.refreshable {
					// For “standard” refresh operations, we only refresh the buses.
					await self.mapState.refreshBuses()
				}
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
		Logging.withLogger { (logger) in
			let formattedVersion: String
			if let version = Bundle.main.version {
				formattedVersion = " \(version)"
			} else {
				formattedVersion = ""
			}
			let formattedBuild: String
			if let build = Bundle.main.build {
				formattedBuild = " (\(build))"
			} else {
				formattedBuild = ""
			}
			logger.log("[\(#fileID):\(#line) \(#function)] Shuttle Tracker App Clip\(formattedVersion)\(formattedBuild)")
		}
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
		LocationUtilities.locationManager.showsBackgroundLocationIndicator = true
	}
	
}
