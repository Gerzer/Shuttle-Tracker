//
//  File.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 10/9/20.
//

import Foundation

struct Coordinate: Equatable, Codable {
	
	var latitude: Double
	var longitude: Double
	
	static func += (_ leftCoordinate: inout Coordinate, _ rightCoordinate: Coordinate) {
		leftCoordinate.latitude += rightCoordinate.latitude
		leftCoordinate.longitude += rightCoordinate.longitude
	}
	
	static func /= (_ coordinate: inout Coordinate, _ divisor: Double) {
		coordinate.latitude /= divisor
		coordinate.longitude /= divisor
	}
	
}
