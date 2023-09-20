//
//  MapViewDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import SwiftUI

final class MapViewDelegate: NSObject, MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			#if os(iOS)
			switch BoardBusManager.globalTravelState {
			case .onBus:
				let markerAnnotationView = MKMarkerAnnotationView()
				markerAnnotationView.annotation = annotation
				markerAnnotationView.displayPriority = .required
				markerAnnotationView.markerTintColor = .systemBlue
				markerAnnotationView.animatesWhenAdded = true
				markerAnnotationView.glyphImage = UIImage(systemName: SFSymbol.user.rawValue)
				return markerAnnotationView
			case .notOnBus:
				return nil
			}
			#endif // os(iOS)
		} else if let customAnnotation = annotation as? CustomAnnotation {
			return customAnnotation.annotationView
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
