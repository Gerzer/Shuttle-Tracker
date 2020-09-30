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
	locationManager.startUpdatingLocation()
}

enum TravelState {
	
	case notOnBus
	case onWestRoute
	case onNorthRoute
	
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

#if os(macOS)
extension NSImage {
	
	func withTintColor(_ color: NSColor) -> NSImage {
		let image = self.copy() as! NSImage
		image.lockFocus()
		color.set()
		let imageRect = NSRect(origin: .zero, size: image.size)
		imageRect.fill(using: .sourceAtop)
		image.unlockFocus()
		return image
	}
	
}
#endif
