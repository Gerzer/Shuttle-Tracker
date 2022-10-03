//
//  LocationManagerDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
	
	func leaveBus(locationManager: CLLocationManager) {
		guard case .onBus = MapState.shared.travelState else {
			return
		}
		MapState.shared.travelState = .notOnBus
		locationManager.stopUpdatingLocation()
	}
	
	// MARK: - CLLocationManagerDelegate
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		LoggingUtilities.logger.log(level: .info, "[\(#function)] Did update locations \(locations)")
		if case .onBus = MapState.shared.travelState {
			// The Core Location documentation promises that the array of locations will contain at least one element
			LocationUtilities.sendToServer(coordinate: locations.last!.coordinate)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		LoggingUtilities.logger.log(level: .info, "[\(#function)] Did fail with error \(error)")
		LoggingUtilities.logger.log(level: .error, "Location update failed: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		LoggingUtilities.logger.log(level: .info, "[\(#function)] Did determine state \(state.rawValue) for \(region)")
		switch state {
		case .inside:
			LoggingUtilities.logger.log(level: .default, "Inside region: \(region)")
			if let beaconRegion = region as? CLBeaconRegion {
				manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
			}
		case .outside:
			LoggingUtilities.logger.log(level: .default, "Outside region: \(region)")
			if region is CLBeaconRegion {
				self.leaveBus(locationManager: manager)
			}
		case .unknown:
			LoggingUtilities.logger.log(level: .default, "Unknown state for region: \(region)")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		LoggingUtilities.logger.log(level: .info, "[\(#function)] Did enter region \(region)")
		if let beaconRegion = region as? CLBeaconRegion {
			manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		LoggingUtilities.logger.log(level: .info, "[\(#function)] Did exit region \(region)")
		if region is CLBeaconRegion {
			self.leaveBus(locationManager: manager)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		LoggingUtilities.logger.log(level: .info, "[\(#function)] Monitoring did fail for region \(region) with error \(error)")
		LoggingUtilities.logger.log(level: .error, "Region monitoring failed: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		LoggingUtilities.logger.log(level: .info, "[\(#function)] Did range \(beacons) satisfying \(beaconConstraint)")
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
			MapState.shared.locationID = UUID()
			MapState.shared.busID = Int(truncating: beacon.major)
			MapState.shared.travelState = .onBus
			manager.startUpdatingLocation()
			manager.stopRangingBeacons(satisfying: beaconConstraint)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
		LoggingUtilities.logger.log(level: .info, "[\(#function)] Did fail ranging for \(beaconConstraint) error \(error)")
		LoggingUtilities.logger.log(level: .error, "[\(#function)] Ranging failed: \(error)")
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		LoggingUtilities.logger.log(level: .info, "[\(#function)] Did change authorization")
		switch manager.authorizationStatus {
		case .notDetermined:
			LoggingUtilities.logger.log(level: .default, "Location authorization status: not determined")
		case .restricted:
			LoggingUtilities.logger.log(level: .default, "Location authorization status: restricted")
		case .denied:
			LoggingUtilities.logger.log(level: .default, "Location authorization status: denied")
		case .authorizedWhenInUse:
			LoggingUtilities.logger.log(level: .default, "Location authorization status: authorized when in use")
		case .authorizedAlways:
			LoggingUtilities.logger.log(level: .default, "Location authorization status: authorized always")
		@unknown default:
			LoggingUtilities.logger.log(level: .error, "Unknown location authorization status")
		}
	}
	
}
