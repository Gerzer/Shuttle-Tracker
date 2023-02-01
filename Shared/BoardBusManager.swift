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
        
        let liveActivityAttributes = LiveActivityAttributes(message: "Sent location")

        let initialContentState = LiveActivityAttributes.ContentState(latitude: 0, longitude: 0, timestamp: Date.now)
        
        if #available(iOS 16.2, *) {
            let activityContent = ActivityContent(state: initialContentState, staleDate: Calendar.current.date(byAdding: .minute, value: 3, to: Date())!)
        
            do {
                try Activity<LiveActivityAttributes>.request(
                    attributes: liveActivityAttributes,
                    content: activityContent)
            } catch (let error) {
                Logging.withLogger(for: .boardBus, doUpload: true) { (logger) in
                    logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Unable to activate live activity, \(error)")
                }
            }
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
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Deactivated Board Bus")
		}
        if #available(iOS 16.1, *) {
            for activity in Activity<LiveActivityAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
		await MainActor.run {
			MapState.mapView?.userLocation.title = self.oldUserLocationTitle
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
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
        
        if #available(iOS 16.2, *) {
            let updatedState = LiveActivityAttributes.ContentState(latitude: coordinate.latitude, longitude: coordinate.longitude, timestamp: Date.now)
            let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
            
            for activity in Activity<LiveActivityAttributes>.activities {
                await activity.update(updatedContent)
            }
        }
        
		do {
			let (_, statusCode) = try await API.updateBus(id: busID, location: location).perform()
			#if !APPCLIP
			await DebugMode.shared.showToast(statusCode: statusCode)
			#endif // !APPCLIP
		} catch let error {
			Logging.withLogger(for: .boardBus, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public) Failed to send location to server: \(error, privacy: .public)")
			}
		}
	}
	
}
