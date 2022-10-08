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
	
	private let mapView = MKMapView(frame: .zero)
	
	func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
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
	
	func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
		self.mapView.delegate = context.coordinator
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
