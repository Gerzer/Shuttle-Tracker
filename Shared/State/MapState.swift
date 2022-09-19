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
	
	weak var mapView: MKMapView?
	
	@Published var buses = [Bus]()
	
	@Published var stops = [Stop]()
	
	@Published var routes = [Route]()
	
	private init() { }
	
}
