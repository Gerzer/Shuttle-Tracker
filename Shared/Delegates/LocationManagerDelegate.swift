//
//  LocationManagerDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard MapState.shared.travelState == .onBus else {
			return
		}
		LocationUtilities.sendToServer(coordinate: locations.last!.coordinate)
	}
    //case on manager auth status to show the toast
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
	
}
