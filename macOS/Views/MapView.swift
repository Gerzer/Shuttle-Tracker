//
//  MapView.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
	
	@EnvironmentObject private var mapState: MapState
	
	private let mapView = MKMapView(frame: .zero)
	
	func makeNSView(context: Context) -> MKMapView {
		self.mapView.delegate = context.coordinator
		self.mapView.showsUserLocation = true
		self.mapView.showsCompass = true
		self.mapView.setVisibleMapRect(MapUtilities.mapRect, animated: true)
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
		return self.mapView
	}
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		self.mapView.delegate = context.coordinator
		let allRoutesOnMap = self.mapState.routes.allSatisfy { (route) -> Bool in
			return nsView.overlays.contains { (overlay) -> Bool in
				if let existingRoute = overlay as? Route, existingRoute == route {
					return true
				}
				return false
			}
		}
		nsView.removeAnnotations(nsView.annotations)
		nsView.addAnnotations(Array(self.mapState.buses))
		nsView.addAnnotations(Array(self.mapState.stops))
		if !allRoutesOnMap {
			nsView.removeOverlays(nsView.overlays)
			nsView.addOverlays(self.mapState.routes)
		}
	}
	
	func makeCoordinator() -> MapViewDelegate {
		return MapViewDelegate()
	}
	
}
