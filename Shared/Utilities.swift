//
//  Utilities.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

var locationManager = CLLocationManager()
let locationManagerDelegate = LocationManagerDelegate()
let originCoordinate = CLLocationCoordinate2D(latitude: 42.735, longitude: -73.688)
var mapRect = MKMapRect(origin: MKMapPoint(originCoordinate), size: MKMapSize(width: 10000, height: 10000))

func configureLocationManager() {
	locationManager.delegate = locationManagerDelegate
	locationManager.requestWhenInUseAuthorization()
}

extension Set {
	
	static func generateUnion(of sets: [Set]) -> Set {
		var newSet = Set()
		sets.forEach { (set) in
			newSet.formUnion(set)
		}
		return newSet
	}
	
}
