//
//  Route.swift
//  Rennselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/12/20.
//

import SwiftUI
import MapKit

class Route: NSObject, Collection, Identifiable {
	
	let startIndex = 0
	lazy var endIndex = self.mapPoints.count - 1
	let mapPoints: [MKMapPoint]
	var color: Color
	var last: MKMapPoint? {
		get {
			return self.mapPoints.last
		}
	}
	var polylineRenderer: MKPolylineRenderer {
		get {
			let polyline = self.mapPoints.withUnsafeBufferPointer { (mapPointsPointer) -> MKPolyline in
				return MKPolyline(points: mapPointsPointer.baseAddress!, count: mapPointsPointer.count)
			}
			let polylineRenderer = MKPolylineRenderer(polyline: polyline)
			#if os(macOS)
			polylineRenderer.strokeColor = NSColor(self.color).withAlphaComponent(0.5)
			#else
			polylineRenderer.strokeColor = UIColor(self.color).withAlphaComponent(0.5)
			#endif
			polylineRenderer.lineWidth = 3
			return polylineRenderer
		}
	}
	
	init(_  mapPoints: [MKMapPoint] = [], color: Color) {
		self.mapPoints = mapPoints
		self.color = color
	}
	
	subscript(position: Int) -> MKMapPoint {
		return self.mapPoints[position]
	}
	
	func index(after oldIndex: Int) -> Int {
		return oldIndex + 1
	}
	
}

extension Route: MKOverlay {
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return originCoordinate
		}
	}
	var boundingMapRect: MKMapRect {
		let minX = self.reduce(into: self.first!.x) { (x, mapPoint) in
			if mapPoint.x < x {
				x = mapPoint.x
			}
		}
		let maxX = self.reduce(into: self.first!.x) { (x, mapPoint) in
			if mapPoint.x > x {
				x = mapPoint.x
			}
		}
		let minY = self.reduce(into: self.first!.y) { (y, mapPoint) in
			if mapPoint.y < y {
				y = mapPoint.y
			}
		}
		let maxY = self.reduce(into: self.first!.x) { (y, mapPoint) in
			if mapPoint.y > y {
				y = mapPoint.y
			}
		}
		return MKMapRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
	}
	
}

extension Array where Element == Route {
	
	static func download(_ routeCallback: @escaping (_ route: Route) -> Void) {
		let url = URL(string: "https://shuttles.rpi.edu/routes")!
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let data = data {
				try! (JSONSerialization.jsonObject(with: data) as! [[String: Any]]).forEach { (rawRoute) in
					guard let routeName = rawRoute["name"] as? String else {
						return
					}
					var color: Color!
					switch routeName {
					case "NEW North Route":
						color = .red
					case "NEW West Route":
						color = .blue
					default:
						return
					}
					guard let rawPoints = rawRoute["points"] as? [[String: Double]] else {
						return
					}
					let mapPoints = rawPoints.map { (rawPoint) in
						return MKMapPoint(CLLocationCoordinate2D(latitude: rawPoint["latitude"]!, longitude: rawPoint["longitude"]!))
					}
					routeCallback(Route(mapPoints, color: color))
				}
			}
		}
		task.resume()
	}
	
}
