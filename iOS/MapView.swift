//
//  MapView.swift
//  Rensselaer Shuttle (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
	
	var mapView = MKMapView(frame: .zero)
	let mapViewDelegate = MapViewDelegate()
	
//	@State private var buses = Set<Bus>()
//	@State private var routes = [Route]()
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
		[Route].download { (route) in
			DispatchQueue.main.async {
				self.mapState.routes.append(route)
			}
		}
		return self.mapView
	}
	
	func updateUIView(_ uiView: MKMapView, context: Context) {
		uiView.addAnnotations(Array(self.mapState.buses))
		uiView.addOverlays(self.mapState.routes)
	}
	
}
