//
//  MapState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import UserNotifications

actor MapState: ObservableObject {
	
	static let shared = MapState()
	
	static weak var mapView: MKMapView?
	
	private(set) var buses = [Bus]()
	
	private(set) var stops = [Stop]()
	
	private(set) var routes = [Route]()
	
	private init() { }
	
	func refreshBuses() async {
		self.buses = await [Bus].download()
		await MainActor.run {
			self.objectWillChange.send()
		}
	}
	
	func refreshAll() async {
		Task { // Dispatch a new task because we don’t need to await the result
			do {
				try await UNUserNotificationCenter.updateBadge()
			} catch let error {
				Logging.withLogger(for: .apns, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to update badge: \(error, privacy: .public)")
				}
			}
		}
		async let buses = [Bus].download()
		async let stops = [Stop].download()
		async let routes = [Route].download()
		self.buses = await buses
		self.stops = await stops
		self.routes = await routes
		await MainActor.run {
			self.objectWillChange.send()
		}
	}
	
	@MainActor
	func resetVisibleMapRect() async {
		Self.mapView?.setVisibleMapRect(
			await self.routes.boundingMapRect,
			edgePadding: MapConstants.mapRectInsets,
			animated: true
		)
	}
	
}
