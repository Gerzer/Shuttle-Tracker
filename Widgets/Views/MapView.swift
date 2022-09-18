//
//  MapView.swift
//  Widgets
//
//  Created by Gabriel Jacoby-Cooper on 9/17/22.
//

import MapKit
import SwiftUI

// TODO: Remove because maps aren’t supported in widgets
struct MapView: UIViewRepresentable {
	
	private let mapView = MKMapView(frame: .zero)
	
	private let stops: [Stop]
	
	private let routes: [Route]
	
	@Binding private var travelState: TravelState
	
	init(stops: [Stop], routes: [Route], travelState: Binding<TravelState>) {
		self.stops = stops
		self.routes = routes
		self._travelState = travelState
	}
	
	func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
		self.mapView.delegate = context.coordinator
		self.mapView.showsUserLocation = true
//		self.mapView.setVisibleMapRect(MapUtilities.Constants.mapRect, animated: true)
//		[Stop].download { (stops) in
//			DispatchQueue.main.async {
//				self.stops = stops
//			}
//		}
//		[Route].download { (routes) in
//			DispatchQueue.main.async {
//				self.routes = routes
//				self.mapView.setVisibleMapRect(
//					self.mapState.routes.boundingMapRect,
//					edgePadding: MapUtilities.Constants.mapRectInsets,
//					animated: true
//				)
//			}
//		}
		return self.mapView
	}
	
	func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
		self.mapView.delegate = context.coordinator
		let allRoutesOnMap = self.routes.allSatisfy { (route) in
			return uiView.overlays.contains { (overlay) in
				if let existingRoute = overlay as? Route, existingRoute == route {
					return true
				}
				return false
			}
		}
		uiView.removeAnnotations(uiView.annotations)
		uiView.addAnnotations(self.stops)
		if !allRoutesOnMap {
			uiView.removeOverlays(uiView.overlays)
			uiView.addOverlays(self.routes)
		}
	}
	
	func makeCoordinator() -> MapViewDelegate {
		return MapViewDelegate(travelState: self.$travelState)
	}
	
}
