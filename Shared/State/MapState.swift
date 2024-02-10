//
//  MapState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
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
        #if !os(watchOS)
		Task { // Dispatch a new task because we don’t need to await the result
			do {
				try await UNUserNotificationCenter.updateBadge()
			} catch let error {
				Logging.withLogger(for: .apns, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to update badge: \(error, privacy: .public)")
				}
			}
		}
        #endif
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
		if #available(iOS 17, macOS 14, *) {
			let dx = (MapConstants.mapRectInsets.left + MapConstants.mapRectInsets.right) * -15
			let dy = (MapConstants.mapRectInsets.top + MapConstants.mapRectInsets.bottom) * -15
            #if !os(watchOS)
			let mapRect = await self.routes.boundingMapRect.insetBy(dx: dx, dy: dy)
			withAnimation {
				position.mapCameraPosition.wrappedValue = .rect(mapRect)
			}
            #endif
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
	
}
