//
//  MapView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
	
	@EnvironmentObject private var mapState: MapState
	
	private let mapView = MKMapView(frame: .zero)
	
	func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
		self.mapView.delegate = context.coordinator
		self.mapView.showsUserLocation = true
		self.mapView.showsCompass = true
		self.mapView.setVisibleMapRect(MapUtilities.Constants.mapRect, animated: true)
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
				self.mapState.mapView?.setVisibleMapRect(
					self.mapState.routes.boundingMapRect,
					edgePadding: MapUtilities.Constants.mapRectInsets,
					animated: true
				)
			}
		}
		self.mapState.mapView = self.mapView
		return self.mapView
	}
	
	func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
		self.mapView.delegate = context.coordinator
		let allRoutesOnMap = self.mapState.routes.allSatisfy { (route) in
			return uiView.overlays.contains { (overlay) in
				if let existingRoute = overlay as? Route, existingRoute == route {
					return true
				}
				return false
			}
		}
		uiView.removeAnnotations(uiView.annotations)
		uiView.addAnnotations(Array(self.mapState.buses))
		uiView.addAnnotations(Array(self.mapState.stops))
		if !allRoutesOnMap {
			uiView.removeOverlays(uiView.overlays)
			uiView.addOverlays(self.mapState.routes)
		}
	}
	
	func makeCoordinator() -> MapViewDelegate {
		return MapViewDelegate()
	}
	
}
