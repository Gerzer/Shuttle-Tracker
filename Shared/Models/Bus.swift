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
	
	static func download() async -> [Bus] {
		return await withCheckedContinuation { (continuation) in
			API.provider.request(.readBuses) { (result) in
				Task {
					let decoder = JSONDecoder()
					decoder.dateDecodingStrategy = .iso8601
					#if !os(macOS)
					let busID = await BoardBusManager.shared.busID
					let travelState = await BoardBusManager.shared.travelState
					#endif // !os(macOS)
					let buses: [Bus]
					do {
						buses = try result.get()
							.map([Bus].self, using: decoder)
							.filter { (bus) -> Bool in
								return bus.location.date.timeIntervalSinceNow > -300
							}
							#if !os(macOS)
							.filter { (bus) in
								switch travelState {
								case .onBus:
									return bus.id != busID
								case .notOnBus:
									return true
								}
							}
							#endif // !os(macOS)
					} catch let error {
						buses = []
						Logging.withLogger(for: .api, doUpload: true) { (logger) in
							logger.log(level: .error, "[\(#fileID):\(#line) \(#function)] Failed to download buses: \(error)")
						}
						throw error
					}
					continuation.resume(returning: buses)
				}
			}
		}
	}
	
}
