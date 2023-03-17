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
	
	@Published var buses = [Bus]()
	
	@Published var stops = [Stop]()
	
	@Published var routes = [Route]()
    
//    var ClosestStopDistance = LocationUtilities.locationManager.//    
//    func ComputeDirection(Location1, Location2) -> String {
//        return Int.random(in: 1...6)
//    }
//
//    let result = rollDice()

   
    
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
