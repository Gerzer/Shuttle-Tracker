//
//  BoardBusManager.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/18/22.
//

import CoreLocation
import HTTPStatus
import ActivityKit

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
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Activated Board Bus")
		}
    
		await MainActor.run {
			self.oldUserLocationTitle = MapState.mapView?.userLocation.title
			MapState.mapView?.userLocation.title = "Bus \(busID)"
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
		}
        if #available(iOS 16.2, *) {
            await DebugMode.shared.startLiveActivity(busID: busID)
        } else {
            // Fallback on earlier versions
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
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Deactivated Board Bus")
		}
		await MainActor.run {
			MapState.mapView?.userLocation.title = self.oldUserLocationTitle
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
		}
        
        if #available(iOS 16.2, *) {
            await DebugMode.shared.endSession()
        } else {
            // No Debug Mode
        }
        
	}
	
	static func sendToServer(coordinate: CLLocationCoordinate2D) async {
		guard let busID = await BoardBusManager.shared.busID, let locationID = await BoardBusManager.shared.locationID else {
			Logging.withLogger(for: .boardBus, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Required bus and location IDs not found while attempting to send location to server")
			}
			return
		}
		let location = Bus.Location(
			id: locationID,
			date: Date(),
			coordinate: coordinate.convertedToCoordinate(),
			type: .user
		)
		do {
			let (_, statusCode) = try await API.updateBus(id: busID, location: location).perform()
            //await DebugMode.shared.showToast(statusCode: statusCode)
            if #available(iOS 16.2, *) {
                await DebugMode.shared.updateSession(statusCode: statusCode, busID: busID)
            } else {
                // No Debug Mode
            }
                
		} catch let error {
			Logging.withLogger(for: .boardBus, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public) Failed to send location to server: \(error, privacy: .public)")
			}
		}
	}
	
}
