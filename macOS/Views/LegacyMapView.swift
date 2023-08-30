//
//  LegacyMapView.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import SwiftUI

struct LegacyMapView: NSViewRepresentable {
	
	@Binding
	private var position: MapCameraPositionWrapper
	
	@EnvironmentObject
	private var mapState: MapState
	
	init(position: Binding<MapCameraPositionWrapper>) {
		self._position = position
	}
	
	func makeNSView(context: Context) -> MKMapView {
		let nsView = MKMapView(frame: .zero)
		Task {
			MapState.mapView = nsView
			await self.mapState.refreshAll()
			await self.mapState.recenter(position: self.$position)
		}
		nsView.delegate = context.coordinator
		nsView.showsUserLocation = true
		nsView.showsCompass = true
		if #available(macOS 13, *) {
			// Set a custom preferred map configuration
			let configuration = MKStandardMapConfiguration(emphasisStyle: .muted)
			configuration.pointOfInterestFilter = .excludingAll
			nsView.preferredConfiguration = configuration
		}
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
