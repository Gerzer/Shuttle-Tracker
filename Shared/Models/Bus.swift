//
//  Bus.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import SwiftUI

final class Bus: NSObject, Sendable, Codable, CustomAnnotation {
	
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
	
	let location: Location
	
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
	
	@MainActor
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
			#if canImport(AppKit)
			markerAnnotationView.glyphImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
			#elseif canImport(UIKit) // canImport(AppKit)
			markerAnnotationView.glyphImage = UIImage(systemName: symbolName)
			#endif // canImport(UIKit)
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
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601
				let buses = try? result
					.get()
					.map([Bus].self, using: decoder)
				Task {
					#if os(iOS)
					let busID = await BoardBusManager.shared.busID
					let travelState = await BoardBusManager.shared.travelState
					#endif // osiOS
					let buses = (buses ?? [])
						.filter { (bus) -> Bool in
							return abs(bus.location.date.timeIntervalSinceNow) < 300
						}
						#if os(iOS)
						.filter { (bus) in
							switch travelState {
							case .onBus:
								return bus.id != busID
							case .notOnBus:
								return true
							}
						}
						#endif // os(iOS)
					continuation.resume(returning: buses)
				}
			}
		}
	}
	
}
