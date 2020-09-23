//
//  MapView.swift
//  Rensselaer Shuttle (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
	
	let mapView = MKMapView(frame: .zero)
	let mapViewDelegate = MapViewDelegate()
	
	@EnvironmentObject var mapState: MapState
	
	func makeUIView(context: Context) -> MKMapView {
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
	
	func updateUIView(_ uiView: MKMapView, context: Context) {
		uiView.delegate = self.mapViewDelegate
		uiView.removeAnnotations(uiView.annotations)
		let allStopIDSets = self.mapState.routes.map { (route) -> Set<Int> in
			return route.stopIDs
		}
		let allStopIDs = Set.generateUnion(of: allStopIDSets)
		let relevantStops = self.mapState.stops.filter { (stop) -> Bool in
			return allStopIDs.contains(stop.id)
		}
		uiView.addAnnotations(Array(self.mapState.buses))
		uiView.addAnnotations(Array(relevantStops))
		uiView.addOverlays(self.mapState.routes)
	}
	
}
