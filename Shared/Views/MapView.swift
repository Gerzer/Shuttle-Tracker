//
//  MapView.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
	
	let mapView = MKMapView(frame: .zero)
	
	@EnvironmentObject var mapState: MapState
	
	func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
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
	
	func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
		self.mapView.delegate = context.coordinator
		let allStopIDSets = self.mapState.routes.map { (route) -> Set<Int> in
			return route.stopIDs
		}
		let allStopIDs = Set.generateUnion(of: allStopIDSets)
		let relevantStops = self.mapState.stops.filter { (stop) -> Bool in
			return allStopIDs.contains(stop.id)
		}
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
		uiView.addAnnotations(Array(relevantStops))
		if !allRoutesOnMap {
			uiView.removeOverlays(uiView.overlays)
			uiView.addOverlays(self.mapState.routes)
		}
	}
	
	func makeCoordinator() -> MapViewDelegate {
		return MapViewDelegate()
	}
	
}
