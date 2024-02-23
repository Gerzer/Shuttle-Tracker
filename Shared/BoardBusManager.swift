//
//  BoardBusManager.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/18/22.
//

import CoreLocation
import StoreKit
import UIKit

@preconcurrency
import UserNotifications

actor BoardBusManager: ObservableObject {
	
	enum TravelState: Equatable {
		
		case onBus(manual: Bool)
		
		case notOnBus
		
	}
	
	private enum NotificationType {
		
		case boardBus
		
		case leaveBus
		
	}
	
	static let shared = BoardBusManager()
	
	static let networkUUID = UUID(uuidString: "3BB7876D-403D-CB84-5E4C-907ADC953F9C")!
	
	static let beaconID = "com.gerzer.shuttletracker.node"
	
	/// The most recent ``travelState`` value for the ``shared`` instance.
	/// - Important: This property is provided so that the travel state can be read in synchronous contexts. Where possible, it’s safer to access ``travelState`` directly in an asynchronous manner.
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
	
	func boardBus(id busID: Int, manually manual: Bool) async {
		// Require that Board Bus be currently inactive
		precondition(.notOnBus ~= self.travelState)
		
		Task { // Dispatch a child task because we don’t need to await the result
			do {
				try await Analytics.upload(eventType: .boardBusActivated(manual: manual))
			} catch {
				Logging.withLogger(for: .api, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
				}
			}
		}
		
		// Toggle showsUserLocation twice to ensure that MapKit picks up the UI changes
		await MainActor.run {
			MapState.mapView?.showsUserLocation.toggle()
		}
		self.busID = busID
		self.locationID = UUID()
		self.travelState = .onBus(manual: manual)
		CLLocationManager.default.startUpdatingLocation()
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Activated Board Bus")
		}
		Task { // Dispatch a child task because we don’t need to await the result
			await MapState.shared.refreshBuses()
		}
		if !manual {
			Task { // Dispatch a child task because we don’t need to await the result
				await self.sendBoardBusNotification(type: .boardBus)
			}
		}
		await MainActor.run {
			ViewState.shared.statusText = .locationData
			ViewState.shared.handles.tripCount?.increment()
			self.oldUserLocationTitle = MapState.mapView?.userLocation.title
			MapState.mapView?.userLocation.title = "Bus \(busID)"
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
		}
	}
	
	func leaveBus() async {
		// Require that Board Bus be currently active
		guard case .onBus(let manual) = self.travelState else {
			preconditionFailure()
		}
		
		if case .background = await UIApplication.shared.applicationState {
			Task { // Dispatch a child task because we don’t need to await the result
				await self.sendBoardBusNotification(type: .leaveBus)
			}
		}
		
		Task { // Dispatch a child task because we don’t need to await the result
			do {
				try await Analytics.upload(eventType: .boardBusDeactivated(manual: manual))
			} catch {
				Logging.withLogger(for: .api, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
				}
			}
		}
		
		// Toggle showsUserLocation twice to ensure that MapKit picks up the UI changes
		await MainActor.run {
			MapState.mapView?.showsUserLocation.toggle()
		}
		self.busID = nil
		self.locationID = nil
		self.travelState = .notOnBus
		CLLocationManager.default.stopUpdatingLocation()
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Deactivated Board Bus")
		}
		Task { // Dispatch a child task because we don’t need to await the result
			await MapState.shared.refreshBuses()
		}
		await MainActor.run {
			ViewState.shared.statusText = manual ? .thanks : .mapRefresh // Don’t bother showing the “thanks” text if Automatic Board Bus was used since the timer to switch to back to “map refresh” might not reliably fire in the background
			MapState.mapView?.userLocation.title = self.oldUserLocationTitle
			self.oldUserLocationTitle = nil
			self.objectWillChange.send()
			MapState.mapView?.showsUserLocation.toggle()
		}
		
		if manual {
			Task { @MainActor in // Dispatch a child task because we don’t need to await the result
				// TODO: Switch to SwiftUI’s requestReview environment value when we drop support for iOS 15
				// Request a review on the App Store
				// This logic uses the legacy SKStoreReviewController class because the newer SwiftUI requestReview environment value requires iOS 16 or newer, and stored properties can’t be gated on OS version.
				let windowScenes = UIApplication.shared.connectedScenes
					.filter { (scene) in
						return scene.activationState == .foregroundActive
					}
					.compactMap { (scene) in
						return scene as? UIWindowScene
					}
				if let windowScene = windowScenes.first {
					SKStoreReviewController.requestReview(in: windowScene)
				}
				
				do {
					if #available(iOS 16, *) {
						try await Task.sleep(for: .seconds(5))
					} else {
						try await Task.sleep(nanoseconds: 5_000_000_000)
					}
				} catch {
					Logging.withLogger(doUpload: true) { (logger) in
						logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Task sleep error: \(error, privacy: .public)")
					}
				}
				ViewState.shared.statusText = .mapRefresh
			}
		}
	}
	
	func updateBusID(with bus: Bus) {
		if let busID = self.busID, busID < 0 {
			self.busID = bus.id
		}
	}
	
	private func sendBoardBusNotification(type: NotificationType) async {
		let content = UNMutableNotificationContent()
		content.title = "Automatic Board Bus"
		switch type {
		case .boardBus:
			content.body = "Shuttle Tracker detected that you’re on a bus and activated Automatic Board Bus."
		case .leaveBus:
			content.body = "Shuttle Tracker detected that you got off the bus and deactivated Automatic Board Bus."
		}
		content.sound = .default
		#if !APPCLIP
		content.interruptionLevel = .timeSensitive
		#endif // !APPCLIP
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // The User Notifications framework doesn’t support immediate notifications
		let request = UNNotificationRequest(identifier: "AutomaticBoardBus", content: content, trigger: trigger)
		do {
			try await UNUserNotificationCenter.requestDefaultAuthorization()
		} catch {
			Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to request notification authorization: \(error, privacy: .public)")
			}
		}
		do {
			try await UNUserNotificationCenter
				.current()
				.add(request)
		} catch {
			Logging.withLogger(for: .boardBus, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to schedule Automatic Board Bus notification: \(error, privacy: .public)")
			}
		}
	}
	
}
