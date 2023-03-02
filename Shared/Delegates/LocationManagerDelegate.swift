//
//  LocationManagerDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//
import CoreLocation
import CoreLocationUI


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("error:: \(error.localizedDescription)")
      }

      func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
          if status == .authorizedWhenInUse {
              manager.requestLocation()
          }
      }

      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          location = locations.last
          
    


      }
    
    
}



class LocationManagerDelegate: NSObject,ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?

    
    func requestLocation() {
          manager.requestLocation()
      }
    
    
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
