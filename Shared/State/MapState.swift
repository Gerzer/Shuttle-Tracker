//
//  MapState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit

actor MapState: ObservableObject {
	
	static let shared = MapState()
	
	static weak var mapView: MKMapView?
	
	private(set) var buses = [Bus]()
	
	private(set) var stops = [Stop]()
	
	private(set) var routes = [Route]()
	
	private init() { }
	
	func refreshBuses() async {
		self.buses = await [Bus].download()
	}
	
	func refreshAll() async {
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
			edgePadding: MapUtilities.Constants.mapRectInsets,
			animated: true
		)
	}
	
}
