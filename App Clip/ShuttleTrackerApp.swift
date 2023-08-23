//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker (App Clip)
//
//  Created by Gabriel Jacoby-Cooper on 9/30/20.
//

import CoreLocation
import StoreKit
import SwiftUI

@main
struct ShuttleTrackerApp: App {
	
	@State
	private var mapCameraPosition: MapCameraPositionWrapper = .default
	
	@ObservedObject
	private var mapState = MapState.shared
	
	@ObservedObject
	private var viewState = ViewState.shared
	
	@ObservedObject
	private var boardBusManager = BoardBusManager.shared
	
	@ObservedObject
	private var appStorageManager = AppStorageManager.shared
	
	private static let sheetStack = SheetStack()
	
	var body: some Scene {
		WindowGroup {
			ContentView(mapCameraPosition: self.$mapCameraPosition)
				.environmentObject(self.mapState)
				.environmentObject(self.viewState)
				.environmentObject(self.boardBusManager)
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
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Shuttle Tracker App Clip\(formattedVersion, privacy: .public)\(formattedBuild, privacy: .public)")
		}
		CLLocationManager.default = CLLocationManager()
		CLLocationManager.default.requestWhenInUseAuthorization()
		CLLocationManager.default.activityType = .automotiveNavigation
		CLLocationManager.default.showsBackgroundLocationIndicator = true
	}
	
}
