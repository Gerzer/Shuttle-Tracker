//
//  ContentView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/30/20.
//

import SwiftUI
import MapKit
import Moya

struct ContentView: View {
	
	enum StatusText: String {
		
		case mapRefresh = "The map automatically refreshes every 5 seconds."
		case locationData = "You're helping out other users with real-time bus location data."
		case thanks = "Thanks for helping other users with real-time bus location data!"
		
	}
	
	let timer = Timer.publish(every: 5, on: .main, in: .common)
		.autoconnect()
	
	var buttonText: String {
		get {
			switch self.mapState.travelState {
			case .onBus:
				return "Leave Bus"
			case .notOnBus:
				return "Board Bus"
			}
		}
	}
	
	@State private var statusText = StatusText.mapRefresh
	
	@State private var doDisableButton = true
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	var body: some View {
		ZStack {
			self.mapView
				.ignoresSafeArea()
			#if os(macOS)
			VStack {
				HStack {
					switch self.viewState.toastType {
					case .some(.legend):
						LegendToast()
							.frame(maxWidth: 250, maxHeight: 100)
							.padding(.top, 50)
							.padding(.leading, 10)
					case .none:
						EmptyView()
					}
					Spacer()
				}
				Spacer()
			}
			#else // os(macOS)
			VStack {
				VisualEffectView(.systemUltraThinMaterial)
					.ignoresSafeArea()
					.frame(height: 0)
				#if !APPCLIP
				switch self.viewState.toastType {
				case .some(.legend):
					LegendToast()
						.padding()
				case .none:
					HStack {
						SecondaryOverlay()
							.padding(.top, 5)
							.padding(.leading, 10)
						Spacer()
					}
				}
				Spacer()
				#endif // !APPCLIP
				HStack {
					Spacer()
					VStack(alignment: .leading) {
						Button {
							switch self.mapState.travelState {
							case .onBus:
								self.mapState.busID = nil
								self.mapState.locationID = nil
								self.mapState.travelState = .notOnBus
								self.statusText = .thanks
								DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
									self.statusText = .mapRefresh
								}
								LocationUtilities.locationManager.stopUpdatingLocation()
							case .notOnBus:
								if self.mapState.busID == nil {
									self.viewState.alertType = .noNearbyBus
								} else {
									self.mapState.travelState = .onBus
									self.statusText = .locationData
									LocationUtilities.locationManager.startUpdatingLocation()
								}
							}
							self.updateButtonState()
						} label: {
							Text(self.buttonText)
								.fontWeight(.semibold)
								.padding(12)
						}
							.buttonStyle(BlockButtonStyle())
							.disabled(self.doDisableButton)
						HStack {
							Text(self.statusText.rawValue)
								.layoutPriority(1)
							Spacer()
							self.refreshButton
								.frame(width: 30)
						}
					}
						.padding()
						.background(ViewUtilities.standardVisualEffectView)
						.cornerRadius(20)
					Spacer()
				}
					.padding()
				#if APPCLIP
				Spacer()
				#endif // APPCLIP
			}
			#endif // os(macOS)
		}
			.sheet(item: self.$viewState.sheetType) {
				[Route].download { (routes) in
					DispatchQueue.main.async {
						self.mapState.routes = routes
					}
				}
			} content: { (sheetType) in
				switch sheetType {
				case .privacy:
					#if os(iOS) && !APPCLIP
					if #available(iOS 15.0, *) {
						PrivacySheet()
							.interactiveDismissDisabled()
					} else {
						PrivacySheet()
					}
					#else // os(iOS) && !APPCLIP
					EmptyView()
					#endif // os(iOS) && !APPCLIP
				case .settings:
					#if os(iOS) && !APPCLIP
					SettingsSheet()
					#else // os(iOS) && !APPCLIP
					EmptyView()
					#endif // os(iOS) && !APPCLIP
				case .info:
					#if os(iOS) && !APPCLIP
					InfoSheet()
					#else // os(iOS) && !APPCLIP
					EmptyView()
					#endif // os(iOS) && !APPCLIP
				}
			}
			.alert(item: self.$viewState.alertType) { (alertType) -> Alert in
				switch alertType {
				case .noNearbyBus:
					let title = Text("No Nearby Stop")
					let message = Text("You can't board a bus if you're not within ten meters of a stop.")
					let dismissButton = Alert.Button.default(Text("Continue"))
					return Alert(title: title, message: message, dismissButton: dismissButton)
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
					guard let location = LocationUtilities.locationManager.location else {
						break
					}
					let closestBus = self.mapState.buses.min { (firstBus, secondBus) -> Bool in
						let firstBusDistance = firstBus.location.convertForCoreLocation().distance(from: location)
						let secondBusDistance = secondBus.location.convertForCoreLocation().distance(from: location)
						return firstBusDistance < secondBusDistance
					}
					let closestStopDistance = self.mapState.stops.reduce(into: Double.greatestFiniteMagnitude) { (distance, stop) in
						let newDistance = stop.location.distance(from: location)
						if newDistance < distance {
							distance = newDistance
						}
					}
					if closestStopDistance < 10 {
						self.mapState.busID = closestBus?.id
						self.mapState.locationID = UUID()
					}
				}
				self.refreshBuses()
			}
	}
	
	private var refreshButton: some View {
		Button(action: self.refreshBuses) {
			Image(systemName: "arrow.clockwise.circle.fill")
				.resizable()
				.aspectRatio(1, contentMode: .fit)
		}
	}
	
	#if os(macOS)
	private var mapView: some View {
		MapView()
			.toolbar {
				ToolbarItem {
					self.refreshButton
				}
			}
			.onAppear {
				NSWindow.allowsAutomaticWindowTabbing = false
			}
	}
	#else // os(macOS)
	private var mapView: some View {
		MapView()
	}
	#endif // os(macOS)
	
	func refreshBuses() {
		[Bus].download { (buses) in
			DispatchQueue.main.async {
				self.mapState.buses = buses
				self.updateButtonState()
			}
		}
//		if let location = locationManager.location {
//			let locationMapPoint = MKMapPoint(location.coordinate)
//			let nearestStop = self.mapState.stops.min { (firstStop, secondStop) in
//				let firstStopDistance = MKMapPoint(firstStop.coordinate).distance(to: locationMapPoint)
//				let secondStopDistance = MKMapPoint(secondStop.coordinate).distance(to: locationMapPoint)
//				return firstStopDistance < secondStopDistance
//			}
//			let busPoints = self.mapState.buses.map { (bus) -> (bus: Bus, mapPoint: MKMapPoint) in
//
//			}
//			self.statusText = "The next bus is \("?") meters away from the nearest stop."
//		}
	}
	
	func updateButtonState() {
		self.doDisableButton = LocationUtilities.locationManager.location == nil || self.mapState.buses.count == 0 && self.mapState.travelState == .notOnBus
	}
	
}

struct ContentViewPreviews: PreviewProvider {
	
	static var previews: some View {
		ContentView()
			.environmentObject(MapState.sharedInstance)
			.environmentObject(ViewState.sharedInstance)
	}
	
}
