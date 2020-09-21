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
		self.mapView.setVisibleMapRect(mapRect, animated: true)
		configureLocationManager()
		Set<Bus>.download { (bus) in
			DispatchQueue.main.async {
				self.mapState.buses.insert(bus)
			}
		}
		Set<Stop>.download { (stop) in
			DispatchQueue.main.async {
				self.mapState.stops.insert(stop)
			}
		}
		[Route].download { (route) in
			DispatchQueue.main.async {
				self.mapState.routes.append(route)
			}
		}
		return self.mapView
	}
	
	func updateUIView(_ uiView: MKMapView, context: Context) {
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
