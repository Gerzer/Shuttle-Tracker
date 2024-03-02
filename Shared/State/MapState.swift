//
//  MapState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import STLogging
import SwiftUI
import UserNotifications

actor MapState: ObservableObject {
	
	static let shared = MapState()
	
    #if !os(watchOS)
	static weak var mapView: MKMapView?
    #endif
	
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
			} catch {
				#log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Failed to update badge: \(error, privacy: .public)")
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
	func recenter(position: Binding<MapCameraPositionWrapper>) async {
		if #available(iOS 17, macOS 14, watchOS 10, *) {
			let dx = (MapConstants.mapRectInsets.left + MapConstants.mapRectInsets.right) * -15
			let dy = (MapConstants.mapRectInsets.top + MapConstants.mapRectInsets.bottom) * -15
			let mapRect = await self.routes.boundingMapRect.insetBy(dx: dx, dy: dy)
			withAnimation {
				position.mapCameraPosition.wrappedValue = .rect(mapRect)
			}
		} else {
            #if !os(watchOS)
			Self.mapView?.setVisibleMapRect(
				await self.routes.boundingMapRect,
				edgePadding: MapConstants.mapRectInsets,
				animated: true
			)
            #endif
		}
	}
	
	func distance(to coordinate: CLLocationCoordinate2D) -> Double {
		return self.routes
			.map { (route) in
				return route.distance(to: coordinate)
			}
			.min() ?? .infinity
	}
	
}
