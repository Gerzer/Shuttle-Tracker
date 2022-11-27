//
//  LocationManagerDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
	
	#if os(iOS)
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		Logging.withLogger(for: .location) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did update locations \(locations, privacy: .private(mask: .hash))")
		}
		Task {
			if case .onBus = await BoardBusManager.shared.travelState {
				// The Core Location documentation promises that the array of locations will contain at least one element
				await LocationUtilities.sendToServer(coordinate: locations.last!.coordinate)
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		Logging.withLogger(for: .location, doUpload: true) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did fail with error \(error, privacy: .public)")
			logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Location update failed: \(error, privacy: .public)")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		Logging.withLogger(for: .location) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did determine state \(state.rawValue) for \(region, privacy: .private(mask: .hash))")
			switch state {
			case .inside:
				logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Inside region: \(region, privacy: .private(mask: .hash))")
				if let beaconRegion = region as? CLBeaconRegion {
					manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
					logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Started ranging beacons: \(beaconRegion, privacy: .public)")
				}
			case .outside:
				logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Outside region: \(region, privacy: .private(mask: .hash))")
				Task {
					if region is CLBeaconRegion, case .onBus(manual: false) = await BoardBusManager.shared.travelState {
						await BoardBusManager.shared.leaveBus()
					}
				}
			case .unknown:
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Unknown state for region: \(region, privacy: .private(mask: .hash))")
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		Logging.withLogger(for: .location) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did enter region \(region, privacy: .private(mask: .hash))")
			if let beaconRegion = region as? CLBeaconRegion {
				manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
				logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Started ranging beacons: \(beaconRegion, privacy: .private(mask: .hash))")
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		Logging.withLogger(for: .location) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did exit region \(region, privacy: .private(mask: .hash))")
			Task {
				if region is CLBeaconRegion, case .onBus(manual: false) = await BoardBusManager.shared.travelState {
					await BoardBusManager.shared.leaveBus()
				}
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		Logging.withLogger(for: .location, doUpload: true) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Monitoring did fail for region \(region, privacy: .private(mask: .hash)) with error \(error, privacy: .public)")
			logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Region monitoring failed: \(error, privacy: .public)")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		Logging.withLogger(for: .location) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did range \(beacons, privacy: .public) satisfying \(beaconConstraint, privacy: .public)")
			Task {
				if case .notOnBus = await BoardBusManager.shared.travelState {
					let beacon = beacons
						.min { (first, second) in // Select the physically nearest beacon
							switch (first.proximity, second.proximity) {
							case (.immediate, .near), (.immediate, .far), (.near, .far):
								return true
							case (.far, .immediate), (.far, .near), (.near, .immediate):
								return false
							case (let firstProximity, .unknown) where firstProximity != .unknown:
								return true // Prefer the first beacon because only it has known proximity
							case (.unknown, let secondProximity) where secondProximity != .unknown:
								return false // Prefer the second beacon because only it has known proximity
							default:
								switch (first.accuracy, second.accuracy) {
								case (let firstAccuracy, let secondAccuracy) where firstAccuracy >= 0 && secondAccuracy < 0:
									return true // Prefer the first beacon because only it has known accuracy
								case (let firstAccuracy, let secondAccuracy) where firstAccuracy < 0 && secondAccuracy >= 0:
									return false // Prefer the second beacon because only it has known accuracy
								default:
									return first.accuracy < second.accuracy // Prefer the beacon with the lower accuracy value, which, per the documentation, typically indicates that it’s nearer
								}
							}
						}
					guard let beacon else {
						logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] No beacons remain after filtering")
						return
					}
					let id = Int(truncating: beacon.major)
					await BoardBusManager.shared.boardBus(id: id, manually: false)
					manager.stopRangingBeacons(satisfying: beaconConstraint)
				}
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
		Logging.withLogger(for: .location, doUpload: true) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did fail ranging for \(beaconConstraint, privacy: .public) error \(error, privacy: .public)")
			logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Ranging failed: \(error, privacy: .public)")
		}
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		Logging.withLogger(for: .location) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did change authorization")
			switch manager.authorizationStatus {
			case .notDetermined:
				logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Location authorization status: not determined")
			case .restricted:
				logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Location authorization status: restricted")
			case .denied:
				logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Location authorization status: denied")
			case .authorizedWhenInUse:
				logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Location authorization status: authorized when in use")
			case .authorizedAlways:
				logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Location authorization status: authorized always")
			@unknown default:
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Unknown location authorization status")
			}
		}
	}
	#endif // os(iOS)
	
}
