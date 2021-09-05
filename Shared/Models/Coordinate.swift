//
//  Coordinate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/4/21.
//

import CoreLocation

struct Coordinate: Codable {
	
	let latitude: Double
	
	let longitude: Double
	
	func convertedForCoreLocation() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}
	
}
