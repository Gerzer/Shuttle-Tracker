//
//  LocationManagerDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
	
	#if !os(macOS)
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		Task {
			guard case .onBus = await BoardBusManager.shared.travelState else {
				return
			}
			await LocationUtilities.sendToServer(coordinate: locations.last!.coordinate)
		}
	}
	#endif // !os(macOS)
	
}
