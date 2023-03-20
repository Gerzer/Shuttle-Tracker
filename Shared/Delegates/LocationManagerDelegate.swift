//
//  LocationManagerDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//
import CoreLocation
import CoreLocationUI


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var stops = [Stop]()

    let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var ClosestStop: CLLocationDistance?


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

          
          
          guard let userLocation = locations.last else {
                 return
             }
             location = userLocation
             
             let stopLocations = stops.map { CLLocation(latitude: $0.location.coordinate.latitude, longitude: $0.location.coordinate.longitude) }
             let nearestStopLocation = stopLocations.min(by: { userLocation.distance(from: $0) < userLocation.distance(from: $1) })
          
             ClosestStop = nearestStopLocation?.distance(from: userLocation) ?? 0
          
          
          
          
        

      }
    
    
}



class LocationManagerDelegate: NSObject,ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var locationTEST: CLLocationCoordinate2D?


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
