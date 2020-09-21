//
//  MapView.swift
//  Rensselaer Shuttle (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
	
	private var mapView = MKMapView(frame: .zero)
	private let mapViewDelegate = MapViewDelegate()
	
	@EnvironmentObject var mapState: MapState
	
	func makeNSView(context: Context) -> MKMapView {
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
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		nsView.addAnnotations(Array(self.mapState.buses))
		nsView.addOverlays(self.mapState.routes)
	}
	
}
