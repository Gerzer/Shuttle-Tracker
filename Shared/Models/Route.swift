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
	
	var mapColor: Color {
		get {
			return self.color
				.opacity(0.7)
		}
	}
	
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
			let minX = self.min { return $0.x < $1.x }?.x
			let maxX = self.max { return $0.x < $1.x }?.x
			let minY = self.min { return $0.y < $1.y }?.y
			let maxY = self.max { return $0.y < $1.y }?.y
			guard let minX, let maxX, let minY, let maxY else {
				return MKMapRect.null
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
	
	func index(after oldIndex: Int) -> Int {
		return oldIndex + 1
	}
	
	func distance(to coordinate: CLLocationCoordinate2D) -> Double {
		var minDistance: Double = -1
		for index in self.mapPoints.indices.dropLast() {
			let vecA = self.mapPoints[index].coordinate.asCartesian()
			let vecB = self.mapPoints[index + 1].coordinate.asCartesian()
			let vecC = coordinate.asCartesian()
			let vecG = vecA * vecB
			let vecF = vecC * vecG
			var vecT = vecG * vecF
			let epsilon = 0.01
			let magnitude = sqrt(vecT.x * vecT.x + vecT.y * vecT.y + vecT.z * vecT.z) + epsilon
			vecT.x *= MapConstants.earthRadius / magnitude
			vecT.y *= MapConstants.earthRadius / magnitude
			vecT.z *= MapConstants.earthRadius / magnitude
			let coordinate = CLLocationCoordinate2D(
				latitude: 180 / .pi * asin(vecT.z / MapConstants.earthRadius),
				longitude: 180 / .pi * atan2(vecT.y, vecT.x)
			)
			let closestPoint = if abs(self.mapPoints[index].distance(to: self.mapPoints[index + 1]) - self.mapPoints[index].distance(to: MKMapPoint(coordinate)) - self.mapPoints[index + 1].distance(to: MKMapPoint(coordinate))) < epsilon {
				MKMapPoint(coordinate)
			} else {
				(self.mapPoints[index].distance(to: MKMapPoint(coordinate)) < self.mapPoints[index + 1].distance(to: MKMapPoint(coordinate))) ? self.mapPoints[index] : self.mapPoints[index + 1]
			}
			let distance = closestPoint.distance(to: MKMapPoint(coordinate))
			if minDistance < 0 || distance < minDistance {
				minDistance = distance
			}
		}
		return minDistance
	}
	
	static func == (_ left: Route, _ right: Route) -> Bool {
		return left.mapPoints == right.mapPoints
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
		} catch {
			Logging.withLogger(for: .api) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to download routes: \(error, privacy: .public)")
			}
			return []
		}
	}
	
}
