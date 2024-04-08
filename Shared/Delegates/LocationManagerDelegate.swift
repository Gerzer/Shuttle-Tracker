//
//  LocationManagerDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import CoreLocation
import STLogging
import SwiftUI

final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
	
	fileprivate static let privateDefault = LocationManagerDelegate()
	
	#if os(iOS) || os(watchOS)
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		#log(system: Logging.system, category: .locationManagerDelegate, level: .info, "Did update locations \(locations, privacy: .private(mask: .hash))")
		Task {
            #if !os(watchOS)
			if case .onBus = await BoardBusManager.shared.travelState {
				// The Core Location documentation promises that the array of locations will contain at least one element.
				await LocationUtilities.sendToServer(coordinate: locations.last!.coordinate)
			}
//			await BoardBusManager.sendToServer(coordinate: locations.last!.coordinate)
            #endif
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
		#log(system: Logging.system, category: .locationManagerDelegate, level: .info, "Did fail with error \(error, privacy: .public)")
		#log(system: Logging.system, category: .location, level: .error, doUpload: true, "Location update failed: \(error, privacy: .public)")
	}
	
    #if !os(watchOS)
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		#log(system: Logging.system, category: .locationManagerDelegate, level: .info, "Did determine state \(state.rawValue) for \(region, privacy: .private(mask: .hash))")
		switch state {
		case .inside:
			#log(system: Logging.system, category: .location, "Inside region: \(region, privacy: .private(mask: .hash))")
			if let beaconRegion = region as? CLBeaconRegion {
				manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
				#log(system: Logging.system, category: .location, level: .info, "Started ranging beacons: \(beaconRegion, privacy: .public)")
			}
		case .outside:
			#log(system: Logging.system, category: .location, "Outside region: \(region, privacy: .private(mask: .hash))")
			Task {
				if region is CLBeaconRegion, case .onBus(manual: false) = await BoardBusManager.shared.travelState {
					await BoardBusManager.shared.leaveBus()
				}
			}
		case .unknown:
			#log(system: Logging.system, category: .location, level: .error, "Unknown state for region: \(region, privacy: .private(mask: .hash))")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		#log(system: Logging.system, category: .locationManagerDelegate, level: .info, "Did enter region \(region, privacy: .private(mask: .hash))")
		if let beaconRegion = region as? CLBeaconRegion {
			manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
			#log(system: Logging.system, category: .location, level: .info, "Started ranging beacons: \(beaconRegion, privacy: .private(mask: .hash))")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		#log(system: Logging.system, category: .locationManagerDelegate, level: .info, "Did exit region \(region, privacy: .private(mask: .hash))")
		Task {
			if region is CLBeaconRegion, case .onBus(manual: false) = await BoardBusManager.shared.travelState {
				await BoardBusManager.shared.leaveBus()
			}
		}
	}
    
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: any Error) {
		#log(system: Logging.system, category: .locationManagerDelegate, level: .info, "Monitoring did fail for region \(region, privacy: .private(mask: .hash)) with error \(error, privacy: .public)")
		#log(system: Logging.system, category: .location, level: .error, doUpload: true, "Region monitoring failed: \(error, privacy: .public)")
	}
	
	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		#log(system: Logging.system, category: .locationManagerDelegate, level: .info, "Did range \(beacons, privacy: .public) satisfying \(beaconConstraint, privacy: .public)")
		Task {
			if case .notOnBus = await BoardBusManager.shared.travelState {
				let beacon = beacons.min { (first, second) in // Select the physically nearest beacon
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
					#log(system: Logging.system, category: .location, level: .error, "No beacons remain after filtering")
					return
				}
				let major = Int(truncating: beacon.major)
				let minor = Int(truncating: beacon.minor)
				let id = major == 0 && minor > 0 ? -minor : major
				await BoardBusManager.shared.boardBus(id: id, manually: false)
				manager.stopRangingBeacons(satisfying: beaconConstraint)
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: any Error) {
		#log(system: Logging.system, category: .locationManagerDelegate, level: .info, "Did fail ranging for \(beaconConstraint, privacy: .public) error \(error, privacy: .public)")
		#log(system: Logging.system, category: .location, level: .error, doUpload: true, "Ranging failed: \(error, privacy: .public)")
	}
    #endif
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		#log(system: Logging.system, category: .locationManagerDelegate, level: .info, "Did change authorization")
		switch manager.authorizationStatus {
		case .notDetermined:
			#log(system: Logging.system, "Location authorization status: not determined")
		case .restricted:
			#log(system: Logging.system, "Location authorization status: restricted")
		case .denied:
			#log(system: Logging.system, "Location authorization status: denied")
		case .authorizedWhenInUse:
			#log(system: Logging.system, "Location authorization status: authorized when in use")
		case .authorizedAlways:
			#log(system: Logging.system, "Location authorization status: authorized always")
		@unknown default:
			#log(system: Logging.system, "Unknown location authorization status")
		}
		#if !APPCLIP
		Task { @MainActor in
			switch (manager.authorizationStatus, manager.accuracyAuthorization) {
			case (.authorizedAlways, .fullAccuracy):
				if case .network = ViewState.shared.toastType {
					withAnimation {
						ViewState.shared.toastType = nil
					}
				}
			case (.authorizedWhenInUse, _):
				manager.requestAlwaysAuthorization()
				fallthrough
			default:
				switch ViewState.shared.toastType {
				case .network:
					break
				default:
					withAnimation {
						ViewState.shared.toastType = .network
					}
				}
			}
		}
		#endif // !APPCLIP
	}
	#endif // os(iOS)
	
}

extension CLLocationManagerDelegate where Self == LocationManagerDelegate {
	
	/// The default location manager delegate, which is automatically set as the delegate for the default location manager.
	static var `default`: Self {
		get {
			return .privateDefault
		}
	}
	
}
