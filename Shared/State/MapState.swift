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
    static let LM = LocationManager()
	
	@Published var buses = [Bus]()
	
	@Published var stops = [Stop]()
	
	@Published var routes = [Route]()
    
    var userLocation = LM.location


    var nearestStopDistance: CLLocationDistance? {
          guard let userLocation = self.userLocation else {
              return nil
          }
          
          let stopLocations = stops.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
          let nearestStopLocation = stopLocations.min(by: { userLocation.distance(from: $0) < userLocation.distance(from: $1) })
          return nearestStopLocation?.distance(from: userLocation)
      }
    
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
