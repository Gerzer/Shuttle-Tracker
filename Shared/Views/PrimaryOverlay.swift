//
//  PrimaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

import SwiftUI
import StoreKit

struct PrimaryOverlay: View {
	
	private let timer = Timer
		.publish(every: 5, on: .main, in: .common)
		.autoconnect()
	
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
	
	@State private var isRefreshing = false
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	@EnvironmentObject private var boardBusManager: BoardBusManager
	
	@AppStorage("MaximumStopDistance") private var maximumStopDistance = 50
	
	var body: some View {
		HStack {
			Spacer()
			VStack(alignment: .leading) {
				Button {
					Task {
						switch await self.boardBusManager.travelState {
						case .onBus:
							await self.boardBusManager.leaveBus()
							self.viewState.statusText = .thanks
							LocationUtilities.locationManager.stopUpdatingLocation()
							
							// Remove any pending leave-bus notifications
							UNUserNotificationCenter
								.current()
								.removeAllPendingNotificationRequests()
							
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
							if #available(iOS 16, *) {
								try await Task.sleep(for: .seconds(5))
							} else {
								try await Task.sleep(nanoseconds: 5_000_000_000)
							}
							self.viewState.statusText = .mapRefresh
						case .notOnBus:
							// TODO: Rename local `location` identifier to something more descriptive
							guard let location = LocationUtilities.locationManager.location else {
								break
							}
							let closestStopDistance = await self.mapState.stops.reduce(into: Double.greatestFiniteMagnitude) { (distance, stop) in
								let newDistance = stop.location.distance(from: location)
								if newDistance < distance {
									distance = newDistance
								}
							}
							if closestStopDistance < Double(self.maximumStopDistance) {
								self.sheetStack.push(.busSelection)
								if self.viewState.toastType == .boardBus {
									self.viewState.toastType = nil
								}
							} else {
								self.viewState.alertType = .noNearbyStop
							}
						}
					}
				} label: {
					Text(self.buttonText)
						.bold()
				}
					.buttonStyle(.block)
				HStack {
					Text(self.viewState.statusText.rawValue)
						.layoutPriority(1)
					Spacer()
					Group {
						if self.isRefreshing {
							ProgressView()
						} else {
							Button {
								if CalendarUtilities.isAprilFools {
									self.sheetStack.push(.plus(featureText: "Refreshing the map"))
								} else {
									NotificationCenter.default.post(name: .refreshBuses, object: nil)
								}
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
					if #available(iOS 16, *) {
						try await Task.sleep(for: .milliseconds(500))
					} else {
						try await Task.sleep(nanoseconds: 500_000_000)
					}
					await self.mapState.refreshAll()
					withAnimation {
						self.isRefreshing = false
					}
				}
			}
			.onReceive(self.timer) { (_) in
				Task {
					switch await self.boardBusManager.travelState {
					case .onBus:
						guard let coordinate = LocationUtilities.locationManager.location?.coordinate else {
							LoggingUtilities.logger.log(level: .info, "User location unavailable")
							break
						}
						await LocationUtilities.sendToServer(coordinate: coordinate)
					case .notOnBus:
						break
					}
					
					// For “standard” refresh operations, we only refresh the buses.
					await self.mapState.refreshBuses()
				}
			}
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
