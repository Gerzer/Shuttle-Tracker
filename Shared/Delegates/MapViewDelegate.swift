//
//  MapViewDelegate.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if let bus = annotation as? Bus {
			return bus.markerAnnotationView
		} else if let stop = annotation as? Stop {
			return stop.pinAnnotationView
		}
		return nil
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if let route = overlay as? Route {
			return route.polylineRenderer
		}
		return MKOverlayRenderer()
	}
	
}
