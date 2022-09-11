//
//  Bus.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

class Bus: NSObject, Codable, CustomAnnotation {
	
	struct Location: Codable {
		
		enum LocationType: String, Codable {
			
			case system
			
			case user
			
		}
		
		let id: UUID
		
		let date: Date
		
		let coordinate: Coordinate
		
		let type: LocationType
		
		func convertedForCoreLocation() -> CLLocation {
			return CLLocation(
				coordinate: self.coordinate.convertedForCoreLocation(),
				altitude: .nan,
				horizontalAccuracy: .nan,
				verticalAccuracy: .nan,
				timestamp: self.date
			)
		}
		
	}
	
	let id: Int
	
	private(set) var location: Location
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return self.location.coordinate.convertedForCoreLocation()
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
			let colorBlindMode = UserDefaults.standard.bool(forKey: "ColorBlindMode")
			let colorBlindSymbolName: String
			switch self.location.type {
			case .system:
				markerAnnotationView.markerTintColor = colorBlindMode ? .systemPurple : .systemRed
				colorBlindSymbolName = "circle.dotted"
			case .user:
				markerAnnotationView.markerTintColor = .systemGreen
				colorBlindSymbolName = "scope"
			}
			let symbolName = colorBlindMode ? colorBlindSymbolName : "bus"
			#if os(macOS)
			markerAnnotationView.glyphImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
			#else // os(macOS)
			markerAnnotationView.glyphImage = UIImage(systemName: symbolName)
			#endif
			return markerAnnotationView
		}
	}
	
	init(id: Int, location: Location) {
		self.id = id
		self.location = location
	}
	
	static func == (_ left: Bus, _ right: Bus) -> Bool {
		return left.id == right.id
	}
	
}

extension Array where Element == Bus {
	
	static func download(_ busesCallback:  @escaping (_ buses: [Bus]) -> Void) {
		API.provider.request(.readBuses) { (result) in
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let buses = try? result
				.get()
				.map([Bus].self, using: decoder)
				.filter { (bus) in
					return bus.location.date.timeIntervalSinceNow > -300
				}
				.filter { (bus) in
					switch MapState.shared.travelState {
					case .onBus:
						return bus.id != MapState.shared.busID
					case .notOnBus:
						return true
					}
				}
			busesCallback(buses ?? [])
		}
	}
	
}
