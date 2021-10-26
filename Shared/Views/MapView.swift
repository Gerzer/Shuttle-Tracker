//
//  MapView.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
	
	private let mapView = MKMapView(frame: .zero)
	
	@EnvironmentObject private var mapState: MapState
	
	func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
		self.mapView.delegate = context.coordinator
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
	
	func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
		self.mapView.delegate = context.coordinator
		let allRoutesOnMap = self.mapState.routes.allSatisfy { (route) -> Bool in
			return uiView.overlays.contains { (overlay) -> Bool in
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
