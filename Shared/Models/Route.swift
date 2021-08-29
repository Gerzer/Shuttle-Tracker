//
//  Route.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/12/20.
//

import SwiftUI
import MapKit

class Route: NSObject, Collection, Identifiable, MKOverlay {
	
	let startIndex = 0
	
	private(set) lazy var endIndex = self.mapPoints.count - 1
	
	let mapPoints: [MKMapPoint]
	
	let stopIDs: Set<Int>
	
	let color: Color
	
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
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return MapUtilities.originCoordinate
		}
	}
	
	var boundingMapRect: MKMapRect {
		get {
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
	
	init(_ mapPoints: [MKMapPoint] = [], stopIDs: Set<Int>, color: Color) {
		self.mapPoints = mapPoints
		self.stopIDs = stopIDs
		self.color = color
	}
	
	subscript(position: Int) -> MKMapPoint {
		return self.mapPoints[position]
	}
	
	static func == (_ leftRoute: Route, _ rightRoute: Route) -> Bool {
		return leftRoute.mapPoints == rightRoute.mapPoints
	}
	
	func index(after oldIndex: Int) -> Int {
		return oldIndex + 1
	}
	
}

extension Array where Element == Route {
	
	static func download(_ routesCallback: @escaping (_ routes: [Route]) -> Void) {
		let url = URL(string: "https://shuttles.rpi.edu/routes")!
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let data = data {
				var routes = [Route]()
				try! (JSONSerialization.jsonObject(with: data) as! [[String: Any]]).forEach { (rawRoute) in
					guard let routeName = rawRoute["name"] as? String, let stopIDs = rawRoute["stop_ids"] as? [Int], let rawPoints = rawRoute["points"] as? [[String: Double]] else {
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
					let mapPoints = rawPoints.map { (rawPoint) -> MKMapPoint in
						return MKMapPoint(CLLocationCoordinate2D(latitude: rawPoint["latitude"]!, longitude: rawPoint["longitude"]!))
					}
					routes.append(Route(mapPoints, stopIDs: Set(stopIDs), color: color))
				}
				routesCallback(routes)
			}
		}
		task.resume()
	}
	
}
