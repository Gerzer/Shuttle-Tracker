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
    
    
    
    @Published var nearestStopDistance = Double.greatestFiniteMagnitude {
         didSet {
             if stops.count > 0 {
                 if let userLocation = LocationUtilities.locationManager.location  {
                     
                     let newDistance = stops.reduce(into: Double.greatestFiniteMagnitude) { (distance, stop) in
                         let newStopDistance = stop.location.distance(from: userLocation)
                         if newStopDistance < distance {
                             distance = newStopDistance
                         }
                     }
                     nearestStopDistance = newDistance
                 }else{
                     nearestStopDistance = 33.2
                 }
             }
         }
     }
    
	
	@Published var busID: Int?
	
	@Published var locationID: UUID?
	
	weak var mapView: MKMapView?
	
	private var oldUserLocationTitle: String?
	
	private init() { }
	
}
