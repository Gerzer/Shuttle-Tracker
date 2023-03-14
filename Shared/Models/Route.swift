//
//  Route.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/12/20.
//

import MapKit
import SwiftUI

class Route: NSObject, Collection, Decodable, Identifiable, MKOverlay {
	
	enum CodingKeys: String, CodingKey {
		
		case coordinates, colorName
		
	}
	
	let startIndex = 0
	
	private(set) lazy var endIndex = self.mapPoints.count - 1
	
	let mapPoints: [MKMapPoint]
	
	var last: MKMapPoint? {
		get {
			return self.mapPoints.last
		}
	}
	
	let color: Color
	
	var polylineRenderer: MKPolylineRenderer {
		get {
			let polyline = self.mapPoints.withUnsafeBufferPointer { (mapPointsPointer) -> MKPolyline in
				return MKPolyline(points: mapPointsPointer.baseAddress!, count: mapPointsPointer.count)
			}
			let polylineRenderer = MKPolylineRenderer(polyline: polyline)
			#if canImport(AppKit)
			polylineRenderer.strokeColor = NSColor(self.color)
				.withAlphaComponent(0.7)
			#elseif canImport(UIKit) // canImport(AppKit)
			polylineRenderer.strokeColor = UIColor(self.color)
				.withAlphaComponent(0.7)
			#endif // canImport(UIKit)
			polylineRenderer.lineWidth = 5
			return polylineRenderer
		}
	}
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return MapConstants.originCoordinate
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
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.mapPoints = try container.decode([Coordinate].self, forKey: .coordinates)
			.map { (coordinate) in
				return MKMapPoint(coordinate)
			}
		self.color = try container.decode(ColorName.self, forKey: .colorName).color
	}
	
	subscript(position: Int) -> MKMapPoint {
		return self.mapPoints[position]
	}
	
	static func == (_ left: Route, _ right: Route) -> Bool {
		return left.mapPoints == right.mapPoints
	}
	
	func index(after oldIndex: Int) -> Int {
		return oldIndex + 1
	}
	
    func distance(coordinate: CLLocationCoordinate2D) -> Double {
        var minDist: Double = -1
        
        for i in mapPoints.indices.dropLast() {
            let magSq = mapPoints[i].distance(to: mapPoints[i + 1]).magnitudeSquared
            let y1 = coordinate.latitude, x1 = coordinate.longitude
            let y2 = mapPoints[i].coordinate.latitude, x2 = mapPoints[i].coordinate.longitude
            let y3 = mapPoints[i + 1].coordinate.latitude, x3 = mapPoints[i + 1].coordinate.longitude
            
            let t = Swift.max(0, Swift.min(1, ((x1 - x2) * (x3 - x2) + (y1 - y2) * (y3 - y2))/magSq))
            let projX = x2 + t * (x3 - x2)
            let projY = y2 + t * (y3 - y2)
            
            let earthRadius = 6378.137;
            let pi = 3.1415926535897;
            let dLat = projY * pi / 180 - y1 * pi / 180;
            let dLon = projX * pi / 180 - x1 * pi / 180;
            let a = sin(dLat/2) * sin(dLat/2) + cos(y1 * pi / 180) * cos(projY * pi / 180) * sin(dLon/2) * sin(dLon/2);
            let c = 2 * atan2(sqrt(a), sqrt(1-a));
            let dist = abs(earthRadius * c * 1000);
            
            if minDist < 0 || dist < minDist {
                minDist = dist
            }
        }
        
        return minDist;
    }
}

extension Array where Element == Route {
	
	var boundingMapRect: MKMapRect {
		get {
			return self.reduce(into: .null) { (partialResult, route) in
				partialResult = partialResult.union(route.boundingMapRect)
			}
		}
	}
	
	static func download() async -> [Route] {
		do {
			return try await API.readRoutes.perform(as: [Route].self)
		} catch let error {
			Logging.withLogger(for: .api, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to download routes: \(error, privacy: .public)")
			}
			return []
		}
	}
	
}
