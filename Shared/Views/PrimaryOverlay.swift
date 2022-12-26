//
//  PrimaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

import AsyncAlgorithms
import CoreLocation
import StoreKit
import SwiftUI

struct PrimaryOverlay: View {
	
	private var buttonText: String {
		get {
			switch BoardBusManager.globalTravelState {
			case .onBus:
				return "Leave Bus"
			case .notOnBus:
				return "Board Bus"
			}
		}
	}
	
	@State
	private var isRefreshing = false
	
	@EnvironmentObject
	private var mapState: MapState
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var boardBusManager: BoardBusManager
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	
	var body: some View {
		HStack {
			Spacer()
			VStack(alignment: .leading) {
				Button {
					Task {
						switch await self.boardBusManager.travelState {
						case .onBus:
							await self.leaveBus()
						case .notOnBus:
							await self.boardBus()
						}
					}
				} label: {
					Text(self.buttonText)
						.bold()
				}
					.buttonStyle(.block)
				HStack {
					Text(self.viewState.statusText.string)
						.layoutPriority(1)
						.accessibilityShowsLargeContentViewer()
					Spacer()
					Group {
						if self.isRefreshing {
							ProgressView()
						} else {
							Button {
								NotificationCenter.default.post(name: .refreshBuses, object: nil)
							} label: {
								Image(systemName: "arrow.clockwise")
									.resizable()
									.aspectRatio(1, contentMode: .fit)
									.symbolVariant(.circle)
									.symbolVariant(.fill)
									.symbolRenderingMode(.multicolor)
							}
						}
					}
						.frame(width: 30)
				}
			}
				.padding()
				.background(.regularMaterial)
				.mask {
					RoundedRectangle(cornerRadius: 20, style: .continuous)
				}
				.shadow(radius: 5)
			Spacer()
		}
			.padding()
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses)) { (_) in
				withAnimation {
					self.isRefreshing = true
				}
				Task {
					do {
						if #available(iOS 16, *) {
							try await Task.sleep(for: .milliseconds(500))
						} else {
							try await Task.sleep(nanoseconds: 500_000_000)
						}
					} catch let error {
						Logging.withLogger(doUpload: true) { (logger) in
							logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Task sleep error: \(error, privacy: .public)")
						}
						throw error
					}
					await self.mapState.refreshAll()
					withAnimation {
						self.isRefreshing = false
					}
				}
			}
			.task {
				if #available(iOS 16, *) {
					let sequence = AsyncTimerSequence(
						interval: .seconds(5),
						clock: .continuous
					)
					for await _ in sequence {
						// For “standard” refresh operations, we only refresh the buses.
						await self.mapState.refreshBuses()
					}
				} else {
					Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
						Task {
							// For “standard” refresh operations, we only refresh the buses.
							await self.mapState.refreshBuses()
						}
					}
				}
			}
	}
	
	private func boardBus(userLocation: CLLocation) async {
		let closestStopDistance = await self.mapState.stops.reduce(into: .greatestFiniteMagnitude) { (distance, stop) in
			let newDistance = stop.location.distance(from: userLocation)
			if newDistance < distance {
				distance = newDistance
			}
		}
		if closestStopDistance < Double(self.appStorageManager.maximumStopDistance) {
			self.sheetStack.push(.busSelection)
			if self.viewState.toastType == .boardBus {
				self.viewState.toastType = nil
			}
		} else {
			self.viewState.alertType = .noNearbyStop
		}
	}
	
	/// Gets the user’s current location.
	///
	/// If the user’s location is unavailable, then this method pushes the permission sheet onto the sheet stack and throws an error.
	/// - Returns: The user’s location.
	/// - Throws: ``UserLocationError/unavailable`` if the user’s location is unavailable.
	func userLocation() throws -> CLLocation {
		if let userLocation = CLLocationManager.default.location {
			return userLocation
		} else {
			self.sheetStack.push(.permissions)
			throw UserLocationError.unavailable
		}
	}
	
	private func boardBus() async {
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] “Board Bus” button tapped")
		}
		let userLocation: CLLocation
		switch CLLocationManager.default.accuracyAuthorization {
		case .fullAccuracy:
			do {
				userLocation = try self.userLocation()
			} catch let error {
				Logging.withLogger(for: .location) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to get user location: \(error, privacy: .public)")
				}
				return
			}
		case .reducedAccuracy:
			do {
				try await CLLocationManager.default.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "BoardBus")
			} catch let error {
				Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Temporary full-accuracy location authorization request failed: \(error, privacy: .public)")
				}
				return
			}
			guard case .fullAccuracy = CLLocationManager.default.accuracyAuthorization else {
				Logging.withLogger(for: .permissions) { (logger) in
					logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] User declined full location accuracy authorization")
				}
				return
			}
			do {
				userLocation = try self.userLocation()
			} catch let error {
				Logging.withLogger(for: .location) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to get user location: \(error, privacy: .public)")
				}
				return
			}
		@unknown default:
			fatalError()
		}
		await self.boardBus(userLocation: userLocation)
	}
	
	private func leaveBus() async {
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] “Leave Bus” button tapped")
		}
		await self.boardBusManager.leaveBus()
		self.viewState.statusText = .thanks
		CLLocationManager.default.stopUpdatingLocation()
		
		// Remove all pending leave-bus notifications
		UNUserNotificationCenter
			.current()
			.removeAllPendingNotificationRequests()
		
		// Request a review on the App Store
		// This logic uses the legacy SKStoreReviewController class because the newer SwiftUI requestReview environment value requires iOS 16 or newer, and stored properties can’t be gated on OS version.
		// TODO: Switch to SwiftUI’s requestReview environment value when we drop support for iOS 15
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
		} catch let error {
			Logging.withLogger(doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Task sleep error: \(error, privacy: .public)")
			}
		}
		self.viewState.statusText = .mapRefresh
	}
	
}

struct PrimaryOverlayPreviews: PreviewProvider {
	
	static var previews: some View {
		PrimaryOverlay()
			.environmentObject(MapState.shared)
			.environmentObject(ViewState.shared)
			.environmentObject(BoardBusManager.shared)
	}
	
}
