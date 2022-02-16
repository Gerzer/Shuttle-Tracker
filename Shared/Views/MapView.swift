//
//  MapView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
	
	@EnvironmentObject private var mapState: MapState
	
	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView(frame: .zero)
		mapView.delegate = context.coordinator
		mapView.showsUserLocation = true
		mapView.showsCompass = true
		mapView.setVisibleMapRect(MapUtilities.mapRect, animated: true)
		[Bus].download { (buses) in
			DispatchQueue.main.async {
				self.mapState.buses = buses
			}
		}
		[Stop].download { (stops) in
			DispatchQueue.main.async {
				self.mapState.stops = stops
			}
		}
		[Route].download { (routes) in
			DispatchQueue.main.async {
				self.mapState.routes = routes
			}
		}
		self.mapState.mapView = mapView
		return mapView
	}
	
	func updateUIView(_ mapView: MKMapView, context: Context) {
		// Remove and re-add all stops if not all of them are already on the map
		let stopsOnMap = mapView.annotations.compactMap { (annotation) in
			return annotation as? Stop
		}
		let areAllStopsOnMap = self.mapState.stops.allSatisfy { (stop) in
			return stopsOnMap.contains { (stopOnMap) in
				return stopOnMap == stop
			}
		}
		if !areAllStopsOnMap {
			DispatchQueue.main.async {
				mapView.removeAnnotations(stopsOnMap)
				mapView.addAnnotations(self.mapState.stops)
			}
		}
		
		// Remove and re-add all routes if not all of them are already on the map
		let routesOnMap = mapView.overlays.compactMap { (overlay) in
			return overlay as? Route
		}
		let areAllRoutesOnMap = self.mapState.routes.allSatisfy { (route) in
			return routesOnMap.contains { (routeOnMap) in
				return routeOnMap == route
			}
		}
		if !areAllRoutesOnMap {
			DispatchQueue.main.async {
				mapView.removeOverlays(routesOnMap)
				mapView.addOverlays(self.mapState.routes)
			}
		}
	}
	
	func makeCoordinator() -> MapViewDelegate {
		return MapViewDelegate()
	}
	
}
