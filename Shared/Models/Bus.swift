//
//  Bus.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit

class Bus: NSObject, Codable, CustomAnnotation {
	
	struct Location: Codable {
		
		struct Coordinate: Codable {
			
			let latitude: Double
			
			let longitude: Double
			
			func convertForCoreLocation() -> CLLocationCoordinate2D {
				return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
			}
			
		}
		
		enum LocationType: String, Codable {
			
			case system = "system"
			case user = "user"
			
		}
		
		let id: UUID
		
		let date: Date
		
		let coordinate: Coordinate
		
		let type: LocationType
		
		func convertForCoreLocation() -> CLLocation {
			return CLLocation(coordinate: self.coordinate.convertForCoreLocation(), altitude: .nan, horizontalAccuracy: .nan, verticalAccuracy: .nan, timestamp: self.date)
		}
		
	}
	
	let id: Int
	
	private(set) var location: Location
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return self.location.coordinate.convertForCoreLocation()
		}
	}
	
	var title: String? {
		get {
			return "Bus \(self.id)"
		}
	}
	
	var subtitle: String? {
		get {
			let formatter = RelativeDateTimeFormatter()
			formatter.dateTimeStyle = .named
			formatter.formattingContext = .standalone
			return formatter.localizedString(for: self.location.date, relativeTo: Date())
		}
	}
	
	var annotationView: MKAnnotationView {
		get {
			let markerAnnotationView = MKMarkerAnnotationView()
			markerAnnotationView.displayPriority = .required
			markerAnnotationView.canShowCallout = true
			switch self.location.type {
			case .system:
				markerAnnotationView.markerTintColor = .systemRed
			case .user:
				markerAnnotationView.markerTintColor = .systemGreen
			}
			#if os(macOS)
			markerAnnotationView.glyphImage = NSImage(systemSymbolName: "bus", accessibilityDescription: nil)
			#else
			markerAnnotationView.glyphImage = UIImage(systemName: "bus")
			#endif
			return markerAnnotationView
		}
	}
	
	init(id: Int, location: Location) {
		self.id = id
		self.location = location
	}
	
	static func == (_ leftBus: Bus, _ rightBus: Bus) -> Bool {
		return leftBus.id == rightBus.id
	}
	
}

extension CLLocationCoordinate2D {
	
	func convertToBusCoordinate() -> Bus.Location.Coordinate {
		return Bus.Location.Coordinate(latitude: self.latitude, longitude: self.longitude)
	}
	
}

extension Array where Element == Bus {
	
	static func download(_ busesCallback:  @escaping (_ buses: [Bus]) -> Void) {
		API.provider.request(.readBuses) { (result) in
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let buses = try? result.value?
				.map([Bus].self, using: decoder)
				.filter { (bus) -> Bool in
					return bus.location.date.timeIntervalSinceNow > -300
				}
			busesCallback(buses ?? [])
		}
	}
	
}
