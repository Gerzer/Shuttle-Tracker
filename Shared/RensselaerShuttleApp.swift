//
//  RensselaerShuttleApp.swift
//  Shared
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import SwiftUI
import MapKit

@main struct RensselaerShuttleApp: App {
	
	#if os(macOS)
	static let barPlacement = ToolbarItemPlacement.automatic
	#else
	static let barPlacement = ToolbarItemPlacement.bottomBar
	#endif
	
	let mapState = MapState()
	let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
	var buttonText: String {
		get {
			switch self.travelState {
			case .notOnBus:
				return "Board Bus"
			case .onWestRoute, .onNorthRoute:
				return "Leave Bus"
			}
		}
	}
	
	@State var travelState = TravelState.notOnBus
	@State var statusText = StatusText.mapRefresh
	@State var sheet = Sheet.board
	@State var doShowSheet = false
	@State var busID: Int?
	@State var locationID: UUID?
	
	var body: some Scene {
		WindowGroup {
			ZStack {
				MapView()
					.environmentObject(self.mapState)
					.ignoresSafeArea()
					.toolbar {
						ToolbarItem(placement: Self.barPlacement) {
							Button(action: self.refreshBuses) {
								Image(systemName: "arrow.clockwise.circle.fill")
							}
						}
					}
					.onReceive(self.timer) { (_) in
						if let busID = self.busID, let locationID = self.locationID, let coordinate = locationManager.location?.coordinate {
							let url = URL(string: "https://shuttle.gerzer.software/buses/\(busID)")!
							let location = Bus.Location(id: locationID, date: Date(), coordinate: coordinate.convertToBusCoordinate())
							let encoder = JSONEncoder()
							encoder.dateEncodingStrategy = .iso8601
							var request = URLRequest(url: url)
							request.httpMethod = "PATCH"
							request.httpBody = try! encoder.encode(location)
							request.addValue("application/json", forHTTPHeaderField: "Content-Type")
							URLSession.shared.dataTask(with: request).resume()
						}
						self.refreshBuses()
					}
				#if !os(macOS)
				VStack {
					HStack {
						Spacer()
						VStack(alignment: .leading) {
							Button {
								switch self.travelState {
								case .notOnBus:
									self.sheet = .board
									self.doShowSheet = true
								case .onWestRoute, .onNorthRoute:
									self.busID = nil
									self.locationID = nil
									self.travelState = .notOnBus
									self.statusText = .thanks
									DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
										self.statusText = .mapRefresh
									}
								}
							} label: {
								Text(self.buttonText)
									.padding(10)
							}
								.buttonStyle(BlockButtonStyle())
							Text(self.statusText.rawValue)
						}
							.padding()
							.background(self.visualEffectView)
							.cornerRadius(20)
						Spacer()
					}
						.padding()
					Spacer()
				}
				#endif
			}
			.sheet(isPresented: self.$doShowSheet) {
				[Route].download { (routes) in
					DispatchQueue.main.async {
						self.mapState.routes = routes
					}
				}
			} content: {
				switch self.sheet {
				case .board:
					ZStack {
						VStack {
							HStack {
								Spacer()
								Button("Close") {
									self.doShowSheet = false
								}
									.padding()
							}
							Spacer()
						}
						VStack {
							Text("Which route did you board?")
							HStack {
								Button {
									self.doShowSheet = false
									self.travelState = .onWestRoute
									self.statusText = .locationData
									self.findClosestBus()
								} label: {
									Text("West Route")
										.padding()
								}
									.buttonStyle(BlockButtonStyle(color: .blue))
									.padding(.leading)
								Button {
									self.doShowSheet = false
									self.travelState = .onNorthRoute
									self.statusText = .locationData
									self.findClosestBus()
								} label: {
									Text("North Route")
										.padding()
								}
									.buttonStyle(BlockButtonStyle(color: .red))
									.padding(.trailing)
							}
						}
					}
				}
			}
		}
	}
	
	#if os(macOS)
	var visualEffectView: some View {
		VisualEffectView(blendingMode: .withinWindow, material: .hudWindow)
	}
	#else
	var visualEffectView: some View {
		VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
	}
	#endif
	
	func refreshBuses() {
		[Bus].download { (buses) in
			DispatchQueue.main.async {
				self.mapState.buses = buses
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
	
	func findClosestBus() {
		guard let location = locationManager.location else {
			return
		}
		let closestBus = self.mapState.buses.min { (firstBus, secondBus) -> Bool in
			let firstBusDistance = firstBus.location.convertForCoreLocation().distance(from: location)
			let secondBusDistance = secondBus.location.convertForCoreLocation().distance(from: location)
			return firstBusDistance < secondBusDistance
		}
		self.busID = closestBus?.id
		self.locationID = UUID()
	}
	
}

enum StatusText: String {
	
	case mapRefresh = "The map automatically refreshes every 5 seconds."
	case locationData = "You're helping out other users with real-time bus location data."
	case thanks = "Thanks for helping other users with real-time bus location data!"
	
}

enum Sheet {
	
	case board
	
}
