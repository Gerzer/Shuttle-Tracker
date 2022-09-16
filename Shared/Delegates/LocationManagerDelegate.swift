//
//  LocationManagerDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if case .onBus = MapState.shared.travelState {
			// The Core Location documentation promises that the array of locations will contain at least one element
			LocationUtilities.sendToServer(coordinate: locations.last!.coordinate)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		LoggingUtilities.logger.log(level: .error, "Location update failed: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		if let beaconRegion = region as? CLBeaconRegion {
			if CLLocationManager.isRangingAvailable() {
				manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		if let beaconRegion = region as? CLBeaconRegion {
			if CLLocationManager.isRangingAvailable() {
				manager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
			}
			if case .onBus = MapState.shared.travelState {
				MapState.shared.travelState = .notOnBus
				LocationUtilities.locationManager.stopUpdatingLocation()
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		LoggingUtilities.logger.log(level: .error, "Monitoring failed for region `\(region)`: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		if case .notOnBus = MapState.shared.travelState {
			let beacon = beacons
				.filter { (beacon) in
					return beacon.proximity != .unknown && beacon.accuracy >= 0
				}
				.min { (lhs, rhs) in
					switch (lhs.proximity, rhs.proximity) {
					case (.immediate, .immediate), (.near, .near), (.far, .far):
						assert(lhs.accuracy >= 0)
						assert(rhs.accuracy >= 0)
						return lhs.accuracy < rhs.accuracy
					case (.far, .immediate):
						return false
					case (.far, .near):
						return false
					case (.near, .immediate):
						return false
					case (.near, .far):
						return false
					case (.immediate, .near):
						return true
					case (.immediate, .far):
						return true
					default:
						fatalError("Beacons with unknown proximity should already have been filtered out!")
					}
				}
			guard let beacon else {
				LoggingUtilities.logger.log(level: .error, "No beacons remain after filtering")
				return
			}
			MapState.shared.busID = Int(truncating: beacon.major)
			MapState.shared.travelState = .onBus
			LocationUtilities.locationManager.startUpdatingLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
		LoggingUtilities.logger.log(level: .error, "Ranging failed for beacon constraint `\(beaconConstraint)`: \(error)")
	}
	
}
