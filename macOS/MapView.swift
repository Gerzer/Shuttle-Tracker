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
		self.mapView.showsCompass = false
		self.mapView.setVisibleMapRect(mapRect, animated: true)
		configureLocationManager()
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
		let allStopIDSets = self.mapState.routes.map { (route) -> Set<Int> in
			return route.stopIDs
		}
		let allStopIDs = Set.generateUnion(of: allStopIDSets)
		let relevantStops = self.mapState.stops.filter { (stop) -> Bool in
			return allStopIDs.contains(stop.id)
		}
		nsView.addAnnotations(Array(self.mapState.buses))
		nsView.addAnnotations(Array(relevantStops))
		nsView.addOverlays(self.mapState.routes)
	}
	
}
