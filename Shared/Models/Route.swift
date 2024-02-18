//
//  Route.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/12/20.
//

import MapKit
import SwiftUI

class Route: NSObject, Collection, Decodable, Identifiable {
	
	enum CodingKeys: String, CodingKey {
		
		case coordinates, colorName
		
	}
	
	let startIndex = 0
	
	private(set) lazy var endIndex = self.mapPoints.count - 1
	
    #if !os(watchOS)
	let mapPoints: [MKMapPoint]
    #else
    let mapPoints: [CLLocationCoordinate2D]
    #endif
	
    #if !os(watchOS)
	var last: MKMapPoint? {
		get {
			return self.mapPoints.last
		}
	}
    #else
    var last: CLLocationCoordinate2D? {
        get {
            return self.mapPoints.last
        }
    }
    #endif
    
    
	let color: Color
	
	var mapColor: Color {
		get {
			return self.color
				.opacity(0.7)
		}
	}
    #if !os(watchOS)
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
    #else
    var polylineRenderer: MapPolyline {
        return MapPolyline.init(coordinates: [])
    }
    #endif
    
	var coordinate: CLLocationCoordinate2D {
		get {
			return MapConstants.originCoordinate
		}
	}
	var boundingMapRect: MKMapRect {
		get {
            #if os(watchOS)
            let minX = self.min { return $0.latitude.magnitude < $1.latitude.magnitude }?.latitude
            let maxX = self.max { return $0.latitude.magnitude < $1.latitude.magnitude }?.latitude
            let minY = self.min { return $0.longitude.magnitude < $1.longitude.magnitude }?.longitude
            let maxY = self.max { return $0.longitude.magnitude < $1.longitude.magnitude }?.longitude
            #else
			let minX = self.min { return $0.x < $1.x }?.x
			let maxX = self.max { return $0.x < $1.x }?.x
			let minY = self.min { return $0.y < $1.y }?.y
			let maxY = self.max { return $0.y < $1.y }?.y
            #endif
			guard let minX, let maxX, let minY, let maxY else {
				return MKMapRect.null
			}
            #if os(watchOS)
            let minPoint = MKMapRect(origin: MKMapPoint.init(CLLocationCoordinate2D.init(latitude: minX, longitude: minY)), size: .init())
            let maxPoint = MKMapRect(origin: MKMapPoint.init(CLLocationCoordinate2D.init(latitude: maxX, longitude: maxY)), size: .init())
            return MKMapRect(x: minPoint.origin.x, y: minPoint.origin.y, width: maxPoint.maxX - minPoint.minX, height: maxPoint.maxY - maxPoint.minY)
            #else
			return MKMapRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            #endif
		}
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
        #if !os(watchOS)
		self.mapPoints = try container.decode([Coordinate].self, forKey: .coordinates)
			.map { (coordinate) in
				return MKMapPoint(coordinate)
			}
        #else
        self.mapPoints = try container.decode([Coordinate].self, forKey: .coordinates)
            .map { (coordinate) in
                return CLLocationCoordinate2D(latitude: coordinate.latitude,
                                              longitude: coordinate.longitude)
            }
        #endif
		self.color = try container.decode(ColorName.self, forKey: .colorName).color
	}
	
    #if !os(watchOS)
	subscript(position: Int) -> MKMapPoint {
		return self.mapPoints[position]
	}
    #else
    subscript(position: Int) -> CLLocationCoordinate2D {
        return self.mapPoints[position]
    }
    #endif
	
	static func == (_ left: Route, _ right: Route) -> Bool {
        #if !os(watchOS)
		return left.mapPoints == right.mapPoints
        #else
        return true
        #endif
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
		} catch {
			Logging.withLogger(for: .api) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to download routes: \(error, privacy: .public)")
			}
			return []
		}
	}
}

#if !os(watchOS)
extension Route: MKOverlay {
    
}
#endif
