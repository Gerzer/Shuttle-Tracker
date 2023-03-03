//
//  BoardBusManager.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/18/22.
//

import UserNotifications

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
		// Require that Board Bus be currently inactive
		precondition(.notOnBus ~= self.travelState)
        
        do {
            try await Analytics.upload(eventType: .boardBusActivated(manual: true))
        } catch {
            Logging.withLogger(for: .api, doUpload: true) { (logger) in
                logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
            }
        }
		
		// Toggle showsUserLocation twice to ensure that MapKit picks up the UI changes
		await MainActor.run {
			MapState.mapView?.showsUserLocation.toggle()
		}
		self.busID = busID
		self.locationID = UUID()
		self.travelState = .onBus
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Activated Board Bus")
		}
		await MainActor.run {
			self.oldUserLocationTitle = MapState.mapView?.userLocation.title
			MapState.mapView?.userLocation.title = "Bus \(busID)"
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
		}
	}
	
	func leaveBus() async {
		// Require that Board Bus be currently active
		precondition(.onBus ~= self.travelState)
        
        do {
            try await Analytics.upload(eventType: .boardBusDeactivated(manual: true))
        } catch {
            Logging.withLogger(for: .api, doUpload: true) { (logger) in
                logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
            }
        }
		
		// Remove all pending leave-bus notifications
		UNUserNotificationCenter
			.current()
			.removeAllPendingNotificationRequests()
		
		// Toggle showsUserLocation twice to ensure that MapKit picks up the UI changes
		await MainActor.run {
			MapState.mapView?.showsUserLocation.toggle()
		}
		self.busID = nil
		self.locationID = nil
		self.travelState = .notOnBus
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Deactivated Board Bus")
		}
		await MainActor.run {
			MapState.mapView?.userLocation.title = self.oldUserLocationTitle
			self.oldUserLocationTitle = nil
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
		}
	}
	
}
