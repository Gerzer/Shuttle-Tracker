//
//  MapView.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
	
	private let mapView = MKMapView(frame: .zero)
	
	private let mapViewDelegate = MapViewDelegate()
	
	@EnvironmentObject private var mapState: MapState
	
	func makeNSView(context: Context) -> MKMapView {
		self.mapView.delegate = self.mapViewDelegate
		self.mapView.showsUserLocation = true
		self.mapView.showsCompass = true
		self.mapView.setVisibleMapRect(MapUtilities.mapRect, animated: true)
		Task {
			self.mapState.buses = await [Bus].download()
			self.mapState.stops = await [Stop].download()
			self.mapState.routes = await [Route].download()
		}
		return self.mapView
	}
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		self.mapView.delegate = self.mapViewDelegate
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
	
}
