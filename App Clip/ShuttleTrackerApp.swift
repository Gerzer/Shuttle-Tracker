//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker (App Clip)
//
//  Created by Gabriel Jacoby-Cooper on 9/30/20.
//

import CoreLocation
import STLogging
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
	
	static let sheetStack = ShuttleTrackerSheetStack()
	
	@UIApplicationDelegateAdaptor(AppDelegate.self)
	private var appDelegate
	
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
		let formattedVersion = if let version = Bundle.main.version { " \(version)" } else { "" }
		let formattedBuild = if let build = Bundle.main.build { " (\(build))" } else { "" }
		#log(system: Logging.system, "Shuttle Tracker App Clip\(formattedVersion, privacy: .public)\(formattedBuild, privacy: .public)")
		CLLocationManager.default = CLLocationManager()
		CLLocationManager.default.requestWhenInUseAuthorization()
		CLLocationManager.default.activityType = .automotiveNavigation
		CLLocationManager.default.showsBackgroundLocationIndicator = true
	}
	
}
