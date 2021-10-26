//
//  PrimaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

import SwiftUI

struct PrimaryOverlay: View {
	
	private let timer = Timer.publish(every: 5, on: .main, in: .common)
		.autoconnect()
	
	private var buttonText: String {
		get {
			switch self.mapState.travelState {
			case .onBus:
				return "Leave Bus"
			case .notOnBus:
				return "Board Bus"
			}
		}
	}
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	@Environment(\.refresh) private var refresh
	
	var body: some View {
		HStack {
			Spacer()
			VStack(alignment: .leading) {
				Button {
					switch self.mapState.travelState {
					case .onBus:
						self.mapState.busID = nil
						self.mapState.locationID = nil
						self.mapState.travelState = .notOnBus
						self.viewState.statusText = .thanks
						DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
							self.viewState.statusText = .mapRefresh
						}
						LocationUtilities.locationManager.stopUpdatingLocation()
					case .notOnBus:
						guard let location = LocationUtilities.locationManager.location else {
							break
						}
						let closestStopDistance = self.mapState.stops.reduce(into: Double.greatestFiniteMagnitude) { (distance, stop) in
							let newDistance = stop.location.distance(from: location)
							if newDistance < distance {
								distance = newDistance
							}
						}
						if closestStopDistance < 20 {
							self.mapState.locationID = UUID()
							self.viewState.sheetType = .busSelection
						} else {
							self.viewState.alertType = .noNearbyStop
						}
					}
				} label: {
					Text(self.buttonText)
						.bold()
				}
					.buttonStyle(BlockButtonStyle())
				HStack {
					Text(self.viewState.statusText.rawValue)
						.layoutPriority(1)
					Spacer()
					Button {
						Task {
							await self.refresh?()
						}
					} label: {
						Image(systemName: "arrow.clockwise.circle.fill")
							.resizable()
							.aspectRatio(1, contentMode: .fit)
					}
						.frame(width: 30)
				}
			}
				.padding()
				.background(VisualEffectView(.systemMaterial))
				.cornerRadius(20)
				.shadow(radius: 5)
			Spacer()
		}
			.padding()
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses, object: nil)) { (_) in
				Task {
					await self.refresh?()
				}
			}
			.onReceive(self.timer) { (_) in
				switch self.mapState.travelState {
				case .onBus:
					guard let coordinate = LocationUtilities.locationManager.location?.coordinate else {
						LoggingUtilities.logger.log(level: .info, "User location unavailable")
						break
					}
					LocationUtilities.sendToServer(coordinate: coordinate)
				case .notOnBus:
					break
				}
				Task {
					await self.refresh?()
				}
			}
	}
	
}

struct PrimaryOverlayPreviews: PreviewProvider {
	
	static var previews: some View {
		PrimaryOverlay()
	}
	
}
