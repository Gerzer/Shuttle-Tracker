//
//  MapView.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import SwiftUI

struct MapView: NSViewRepresentable {
	
	private let mapView = MKMapView(frame: .zero)
	
	@EnvironmentObject
	private var mapState: MapState
	
	func makeNSView(context: Context) -> MKMapView {
		Task {
			MapState.mapView = self.mapView
			await self.mapState.refreshAll()
			await self.mapState.resetVisibleMapRect()
		}
		self.mapView.delegate = context.coordinator
		self.mapView.showsUserLocation = true
		self.mapView.showsCompass = true
		return self.mapView
	}
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		self.mapView.delegate = context.coordinator
		Task {
			let buses = await self.mapState.buses
			let stops = await self.mapState.stops
			let routes = await self.mapState.routes
			await MainActor.run {
				let allRoutesOnMap = routes.allSatisfy { (route) in
					return nsView.overlays.contains { (overlay) in
						if let existingRoute = overlay as? Route, existingRoute == route {
							return true
						}
						return false
					}
				}
				nsView.removeAnnotations(nsView.annotations)
				nsView.addAnnotations(buses)
				nsView.addAnnotations(stops)
				if !allRoutesOnMap {
					nsView.removeOverlays(nsView.overlays)
					nsView.addOverlays(routes)
				}
			}
		}
	}
	
	func makeCoordinator() -> MapViewDelegate {
		return MapViewDelegate()
	}
	
}
