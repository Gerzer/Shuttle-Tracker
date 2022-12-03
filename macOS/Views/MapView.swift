//
//  MapView.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import SwiftUI

struct MapView: NSViewRepresentable {
	
	@EnvironmentObject
	private var mapState: MapState
	
	func makeNSView(context: Context) -> MKMapView {
		let nsView = MKMapView(frame: .zero)
		Task {
			MapState.mapView = nsView
			await self.mapState.refreshAll()
			await self.mapState.resetVisibleMapRect()
		}
		nsView.delegate = context.coordinator
		nsView.showsUserLocation = true
		nsView.showsCompass = true
		return nsView
	}
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		nsView.delegate = context.coordinator
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
