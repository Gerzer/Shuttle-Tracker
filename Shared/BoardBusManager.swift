//
//  BoardBusManager.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/18/22.
//

import UserNotifications

actor BoardBusManager: ObservableObject {
	
	enum TravelState: Equatable {
		
		case onBus(manual: Bool)
		
		case notOnBus
		
	}
	
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
	
	func boardBus(id busID: Int, manually isManual: Bool) async {
		precondition(.notOnBus ~= self.travelState)
		await MainActor.run {
			MapState.mapView?.showsUserLocation.toggle()
		}
		self.busID = busID
		self.locationID = UUID()
		self.travelState = .onBus(manual: isManual)
		LocationUtilities.locationManager.startUpdatingLocation()
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Activated Board Bus")
		}
		if !isManual {
			// Schedule Automatic Board Bus notification
			let content = UNMutableNotificationContent()
			content.title = "Automatic Board Bus"
			content.body = "Shuttle Tracker detected that you’re on a bus and activated Automatic Board Bus."
			content.sound = .default
			#if !APPCLIP
			content.interruptionLevel = .timeSensitive
			#endif // !APPCLIP
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // The User Notifications framework doesn’t support immediate notifications
			let request = UNNotificationRequest(identifier: "AutomaticBoardBus", content: content, trigger: trigger)
			do {
				try await UserNotificationUtilities.requestAuthorization()
			} catch let error {
				Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function)] Failed to request notification authorization: \(error)")
				}
			}
			do {
				try await UNUserNotificationCenter
					.current()
					.add(request)
			} catch let error {
				Logging.withLogger(for: .boardBus, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function)] Failed to schedule Automatic Board Bus notification: \(error)")
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
		guard case .onBus = self.travelState else {
			preconditionFailure()
		}
		await MainActor.run {
			MapState.mapView?.showsUserLocation.toggle()
		}
		self.busID = nil
		self.locationID = nil
		self.travelState = .notOnBus
		LocationUtilities.locationManager.stopUpdatingLocation()
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Deactivated Board Bus")
		}
		await MainActor.run {
			MapState.mapView?.userLocation.title = self.oldUserLocationTitle
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
		}
	}
	
}
