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
            if ActivityAuthorizationInfo().areActivitiesEnabled {
                // Create the activity attributes and activity content objects.
                // ...
                var future = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
                future = Calendar.current.date(byAdding: .second, value: 60, to: future)!
                let date = Date.now...future
                
                let initialContentState = DebugModeActivityAttributes.ContentState(status: "No bugs")
                let debugModeActivityAttributes = DebugModeActivityAttributes(name: "Hello")
                var activityContent = ActivityContent(state: initialContentState,
                                                      staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date()))
                
                //let updatedDeliveryStatus = PizzaDeliveryAttributes.PizzaDeliveryStatus(driverName: "Anne Johnson", deliveryTimer: date)
//                let updatedStatus = debugModeActivityAttributes.
//                let updatedContent = ActivityContent(state: updatedDeliveryStatus, staleDate: nil)
//
//                await
                
                // Start the Live Activity.
                do {
                    try Activity.request(attributes: debugModeActivityAttributes ,
                                                            content: activityContent)
                    print("Started debug mode for live activity")
                } catch (let error) {
                    print("Error requesting Live Activity. Reason is: \(error.localizedDescription).")
                }
            }
        } else {
            print("No live activity available on this device .\n")
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
//        let finalDeliveryStatus = PizzaDeliveryAttributes.PizzaDeliveryStatus(driverName: "Anne Johnson", deliveryTimer: Date.now...Date())
//        let finalContent = ActivityContent(state: finalDeliveryStatus, staleDate: nil)
        Task {
            if #available(iOS 16.2, *) {
                for activity in Activity<DebugModeActivityAttributes>.activities {
                    //                await activity.end(nil, dismissalPolicy: .default)
                    
                    await activity.end(nil)
                    print("Ending the Live Activity: \(activity.id)")
                }
            } else {
                // Fallback on earlier versions
            }
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
