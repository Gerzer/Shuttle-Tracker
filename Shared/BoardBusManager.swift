//
//  BoardBusManager.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/18/22.
//

import Combine
import Foundation

actor BoardBusManager: ObservableObject {
	
	static let shared = BoardBusManager()
	
	@MainActor private var oldUserLocationTitle: String?
	
	@Published private(set) var busID: Int?
	
	@Published private(set) var locationID: UUID?
	
	@Published private(set) var travelState = TravelState.notOnBus
	
	private init() { }
	
	func boardBus(busID: Int) async {
		precondition(self.travelState == .notOnBus)
//		MapState.shared.mapView?.showsUserLocation.toggle()
		self.busID = busID
		self.locationID = UUID()
		self.travelState = .onBus
		await MainActor.run {
			self.oldUserLocationTitle = MapState.shared.mapView?.userLocation.title
			MapState.shared.mapView?.userLocation.title = "Bus \(busID)"
		}
//		MapState.shared.mapView?.showsUserLocation.toggle()
	}
	
	func leaveBus() async {
		precondition(self.travelState == .onBus)
//		MapState.shared.mapView?.showsUserLocation.toggle()
		self.busID = nil
		self.locationID = nil
		self.travelState = .notOnBus
		await MainActor.run {
			MapState.shared.mapView?.userLocation.title = self.oldUserLocationTitle
		}
//		MapState.shared.mapView?.showsUserLocation.toggle()
	}
	
}
