//
//  MapView.swift
//  Rensselaer Shuttle (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
	
	let mapView = MKMapView(frame: .zero)
	
	let mapViewDelegate = MapViewDelegate()
	
	@EnvironmentObject var mapState: MapState
	
	func makeNSView(context: Context) -> MKMapView {
		self.mapView.delegate = self.mapViewDelegate
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
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		self.mapView.delegate = self.mapViewDelegate
		let allStopIDSets = self.mapState.routes.map { (route) -> Set<Int> in
			return route.stopIDs
		}
		let allStopIDs = Set.generateUnion(of: allStopIDSets)
		let relevantStops = self.mapState.stops.filter { (stop) -> Bool in
			return allStopIDs.contains(stop.id)
		}
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
		nsView.addAnnotations(Array(relevantStops))
		if !allRoutesOnMap {
			nsView.removeOverlays(nsView.overlays)
			nsView.addOverlays(self.mapState.routes)
		}
	}
	
}
