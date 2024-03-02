//
//  PrimaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

import AsyncAlgorithms
import CoreLocation
import STLogging
import SwiftUI

struct PrimaryOverlay: View {
	
	@State
	private var isRefreshing = false
	
	@State
	private var doShowLocationPermissionsAlert = false
	
	@Binding
	private var mapCameraPosition: MapCameraPositionWrapper
	
	@EnvironmentObject
	private var mapState: MapState
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var boardBusManager: BoardBusManager
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
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
						.animation(.default, value: self.viewState.statusText)
						.accessibilityShowsLargeContentViewer()
					Spacer()
					Group {
						if self.isRefreshing {
							ProgressView()
						} else {
							Button {
								if #available(iOS 16, *) {
									Task {
										await self.viewState.refreshSequence.trigger()
									}
								} else {
									NotificationCenter.default.post(name: .refreshBuses, object: nil)
								}
							} label: {
								Image(systemName: SFSymbol.refresh.systemName)
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
			.alert("Location Access", isPresented: self.$doShowLocationPermissionsAlert) {
				Link("Continue", destination: URL(string: UIApplication.openSettingsURLString)!)
			} message: {
				Text("Shuttle Tracker requires access to your location. Enable precise location access in Settings.")
			}
			.task {
				if #available(iOS 16, *) {
					await self.mapState.refreshAll()
					await self.mapState.recenter(position: self.$mapCameraPosition)
					for await refreshType in self.viewState.refreshSequence { // Wait for the next refresh event to be emitted
						switch refreshType {
						case .manual:
							withAnimation {
								self.isRefreshing = true
							}
							do {
								// This artificial half-second delay makes the user feel like the app is “thinking”, which improves user satisfaction, even when the actual network request would take less time to complete.
								try await Task.sleep(for: .milliseconds(500))
							} catch {
								#log(system: Logging.system, level: .error, doUpload: true, "Task sleep failed: \(error, privacy: .public)")
							}
							
							// For automatic refresh operations, we refresh everything.
							await self.mapState.refreshAll()
							
							withAnimation {
								self.isRefreshing = false
							}
						case .automatic:
							// For automatic refresh operations, we only refresh the buses.
							await self.mapState.refreshBuses()
						}
					}
				} else {
					Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
						Task {
							// For automatic refresh operations, we only refresh the buses.
							await self.mapState.refreshBuses()
						}
					}
				}
			}
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses)) { (_) in // TODO: Remove when we drop support for iOS 15
				if #available(iOS 16, *) {
					#log(system: Logging.system, level: .error, doUpload: true, "Combine publisher for refreshing buses was used even though iOS 16 is available!")
				} else {
					withAnimation {
						self.isRefreshing = true
					}
					Task {
						do {
							// This artificial half-second delay makes the user feel like the app is “thinking”, which improves user satisfaction, even when the actual network request would take less time to complete.
							try await Task.sleep(nanoseconds: 500_000_000)
						} catch {
							#log(system: Logging.system, level: .error, doUpload: true, "Task sleep failed: \(error, privacy: .public)")
						}
						
						// For automatic refresh operations, we refresh everything.
						await self.mapState.refreshAll()
						
						withAnimation {
							self.isRefreshing = false
						}
					}
				}
			}
	}
	
	init(mapCameraPosition: Binding<MapCameraPositionWrapper>) {
		self._mapCameraPosition = mapCameraPosition
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
			#if APPCLIP
			self.doShowLocationPermissionsAlert = true
			#else // APPCLIP
			self.sheetStack.push(.permissions)
			#endif
			throw UserLocationError.unavailable
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
	
	private func boardBus() async {
		#log(system: Logging.system, category: .boardBus, level: .info, "“Board Bus” button tapped")
		
		Task { // Dispatch a child task because we don’t need to await the result
			do {
				try await Analytics.upload(eventType: .boardBusTapped)
			} catch {
				#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to upload analytics: \(error, privacy: .public)")
			}
		}
		
		switch CLLocationManager.default.authorizationStatus {
		case .authorizedAlways, .authorizedWhenInUse:
			break
		default:
			#if APPCLIP
			self.doShowLocationPermissionsAlert = true
			#else // APPCLIP
			self.sheetStack.push(.permissions)
			#endif
		}
		
		let userLocation: CLLocation
		switch CLLocationManager.default.accuracyAuthorization {
		case .fullAccuracy:
			do {
				userLocation = try self.userLocation()
			} catch {
				#log(system: Logging.system, category: .location, level: .error, "Failed to get user location: \(error, privacy: .public)")
				return
			}
		case .reducedAccuracy:
			do {
				try await CLLocationManager.default.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "BoardBus")
			} catch {
				#log(system: Logging.system, category: .permissions, level: .error, doUpload: true, "Temporary full-accuracy location authorization request failed: \(error, privacy: .public)")
				return
			}
			
			guard case .fullAccuracy = CLLocationManager.default.accuracyAuthorization else {
				#log(system: Logging.system, category: .permissions, "User declined full location accuracy authorization")
				return
			}
			
			do {
				userLocation = try self.userLocation()
			} catch {
				#log(system: Logging.system, category: .location, level: .error, "Failed to get user location: \(error, privacy: .public)")
				return
			}
		@unknown default:
			fatalError()
		}
		
		await self.boardBus(userLocation: userLocation)
	}
	
	private func leaveBus() async {
		#log(system: Logging.system, category: .boardBus, level: .info, "“Leave Bus” button tapped")
		
		Task { // Dispatch a child task because we don’t need to await the result
			do {
				try await Analytics.upload(eventType: .leaveBusTapped)
			} catch {
				#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to upload analytics: \(error, privacy: .public)")
			}
		}
		
		await self.boardBusManager.leaveBus()
	}
	
}

@available(iOS 17, *)
#Preview {
	PrimaryOverlay(mapCameraPosition: .constant(MapCameraPositionWrapper(MapConstants.defaultCameraPosition)))
		.environmentObject(MapState.shared)
		.environmentObject(ViewState.shared)
		.environmentObject(BoardBusManager.shared)
}
