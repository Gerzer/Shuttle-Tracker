//
//  MapView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
	
	@EnvironmentObject
	private var mapState: MapState
	
	func makeUIView(context: Context) -> MKMapView {
		let uiView = MKMapView(frame: .zero)
		Task {
			MapState.mapView = uiView
			await self.mapState.refreshAll()
			await self.mapState.resetVisibleMapRect()
		}
		uiView.delegate = context.coordinator
		uiView.showsUserLocation = true
		uiView.showsCompass = true
		return uiView
	}
	
	func updateUIView(_ uiView: MKMapView, context: Context) {
		uiView.delegate = context.coordinator
		Task {
			let buses = await self.mapState.buses
			let stops = await self.mapState.stops
			let routes = await self.mapState.routes
			await MainActor.run {
				let allRoutesOnMap = routes.allSatisfy { (route) in
					return uiView.overlays.contains { (overlay) in
						if let existingRoute = overlay as? Route, existingRoute == route {
							return true
						}
						return false
					}
				}
				uiView.removeAnnotations(uiView.annotations)
				uiView.addAnnotations(buses)
				uiView.addAnnotations(stops)
				if !allRoutesOnMap {
					uiView.removeOverlays(uiView.overlays)
					uiView.addOverlays(routes)
				}
			}
		}
	}
	
	func makeCoordinator() -> MapViewDelegate {
		return MapViewDelegate()
	}
	
}
