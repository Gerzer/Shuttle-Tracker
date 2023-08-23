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
			let minX = self.min { (left, right) in
				return left.x < right.x
			}?.x
			let maxX = self.max { (left, right) in
				return left.x < right.x
			}?.x
			let minY = self.min { (left, right) in
				return left.y < right.y
			}?.y
			let maxY = self.max { (left, right) in
				return left.y < right.y
			}?.y
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
	
	static func == (_ left: Route, _ right: Route) -> Bool {
		return left.mapPoints == right.mapPoints
	}
	
	func index(after oldIndex: Int) -> Int {
		return oldIndex + 1
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
			Logging.withLogger(for: .api) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to download routes: \(error, privacy: .public)")
			}
			return []
		}
	}
	
}
