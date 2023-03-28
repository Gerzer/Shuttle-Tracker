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
	
    func toCartesian(coordinate: CLLocationCoordinate2D) -> (Double, Double, Double) {
        let earthRadius = 6378.137;
        let pi = 3.1415926535897;
        
        return (earthRadius * cos(coordinate.latitude * pi / 180) * cos(coordinate.longitude * pi / 180), earthRadius * cos(coordinate.latitude * pi / 180) * sin(coordinate.longitude * pi / 180), earthRadius * sin(coordinate.latitude * pi / 180));
    }
    
    func crossProduct(_ vecA: (Double, Double, Double), _ vecB: (Double, Double, Double)) -> (Double, Double, Double) {
        return (vecA.1 * vecB.2 - vecA.2 * vecB.1, vecA.2 * vecB.0 - vecA.0 * vecB.2, vecA.0 * vecB.1 - vecA.1 * vecB.0);
    }
    
    func distance(coordinate: CLLocationCoordinate2D) -> Double {
        var minDist: Double = -1
        
        for i in mapPoints.indices.dropLast() {
            let earthRadius = 6378.137;
            let pi = 3.1415926535897;
            
            let vecA = toCartesian(coordinate: mapPoints[i].coordinate)
            let vecB = toCartesian(coordinate: mapPoints[i + 1].coordinate)
            let vecC = toCartesian(coordinate: coordinate)
            
            let epsilon = 0.01
            let vecG = crossProduct(vecA, vecB)
            let vecF = crossProduct(vecC, vecG)
            var vecT = crossProduct(vecG, vecF)
            let mag = sqrt(vecT.0 * vecT.0 + vecT.1 * vecT.1 + vecT.2 * vecT.2) + epsilon
            vecT.0 *= earthRadius / mag
            vecT.1 *= earthRadius / mag
            vecT.2 *= earthRadius / mag
            
            let coord = CLLocationCoordinate2D(latitude: 180 / pi *  asin(vecT.2 / earthRadius), longitude: 180 / pi * atan2(vecT.1, vecT.0))
            
            let closest: MKMapPoint
            
            if abs(mapPoints[i].distance(to: mapPoints[i + 1]) - mapPoints[i].distance(to: MKMapPoint(coord)) - mapPoints[i + 1].distance(to: MKMapPoint(coord))) < epsilon {
                closest = MKMapPoint(coord)
            } else {
                closest = (mapPoints[i].distance(to: MKMapPoint(coordinate)) < mapPoints[i + 1].distance(to: MKMapPoint(coordinate))) ? mapPoints[i] : mapPoints[i + 1]
            }
            
            let dist = closest.distance(to: MKMapPoint(coordinate))
            
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
