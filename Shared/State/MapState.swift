//
//  MapState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import Combine
import MapKit

class MapState: ObservableObject {
	
	static let shared = MapState()
	
	@Published var buses = [Bus]() {
		willSet {
			let busesPairs = self.buses.map { (bus) in
				return (bus.id, bus)
			}
			let busesDictionary = Dictionary(uniqueKeysWithValues: busesPairs)
			for newBus in newValue {
				guard let oldBus = busesDictionary[newBus.id] else {
					DispatchQueue.main.async {
						self.mapView?.addAnnotation(newBus)
					}
					continue
				}
				if newBus.coordinate != oldBus.coordinate {
					let busesToRemove = self.mapView?.annotations.filter { (annotation) in
						guard let bus = annotation as? Bus else {
							return false
						}
						return bus.id == newBus.id
					}
					guard let busesToRemove = busesToRemove else {
						continue
					}
					DispatchQueue.main.async {
						self.mapView?.removeAnnotations(busesToRemove)
						self.mapView?.addAnnotation(newBus)
					}
				}
			}
		}
	}
	
	@Published var stops = [Stop]()
	
	@Published var routes = [Route]()
	
	@Published var travelState = TravelState.notOnBus {
		didSet {
			switch self.travelState {
			case .onBus:
				self.mapView?.showsUserLocation.toggle()
				if let busID = self.busID {
					self.oldUserLocationTitle = self.mapView?.userLocation.title
					self.mapView?.userLocation.title = "Bus \(busID)"
				}
				self.mapView?.showsUserLocation.toggle()
			case .notOnBus:
				self.mapView?.showsUserLocation.toggle()
				self.mapView?.userLocation.title = self.oldUserLocationTitle
				self.mapView?.showsUserLocation.toggle()
			}
		}
	}
	
	@Published var busID: Int?
	
	@Published var locationID: UUID?
	
	weak var mapView: MKMapView?
	
	private var oldUserLocationTitle: String?
	
	private init() { }
	
}
