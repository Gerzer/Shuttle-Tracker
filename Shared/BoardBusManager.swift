//
//  BoardBusManager.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/18/22.
//

import Foundation

actor BoardBusManager: ObservableObject {
	
	static let shared = BoardBusManager()
	
	/// The most recent ``travelState`` value for the ``shared`` instance.
	///
	/// This property is provided so that the travel state can be read in synchronous contexts. Where possible, it’s safer to access ``travelState`` directly in an asynchronous manner.
	private(set) static var globalTravelState: TravelState = .notOnBus
	
	private(set) var busID: Int?
	
	private(set) var locationID: UUID?
	
	private(set) var travelState: TravelState = .notOnBus {
		didSet {
			Self.globalTravelState = self.travelState
		}
	}
	
	@MainActor
	private var oldUserLocationTitle: String?
	
	private init() { }
	
	func boardBus(id busID: Int) async {
		precondition(.notOnBus ~= self.travelState)
		await MainActor.run {
			MapState.mapView?.showsUserLocation.toggle()
		}
		self.busID = busID
		self.locationID = UUID()
		self.travelState = .onBus
		LocationUtilities.locationManager.startUpdatingLocation()
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function)] Activated Board Bus")
		}
		await MainActor.run {
			self.oldUserLocationTitle = MapState.mapView?.userLocation.title
			MapState.mapView?.userLocation.title = "Bus \(busID)"
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
		}
	}
	
	func leaveBus() async {
		precondition(.onBus ~= self.travelState)
		await MainActor.run {
			MapState.mapView?.showsUserLocation.toggle()
		}
		self.busID = nil
		self.locationID = nil
		self.travelState = .notOnBus
		LocationUtilities.locationManager.stopUpdatingLocation()
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function)] Deactivated Board Bus")
		}
		await MainActor.run {
			MapState.mapView?.userLocation.title = self.oldUserLocationTitle
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
		}
	}
	
}
