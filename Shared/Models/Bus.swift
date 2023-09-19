//
//  Bus.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import SwiftUI

class Bus: NSObject, Codable, Identifiable, CustomAnnotation {
	
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
	
	@MainActor
	var tintColor: Color {
		get {
			switch self.location.type {
			case .system:
				return AppStorageManager.shared.colorBlindMode ? .purple : .red
			case .user:
				return .green
			}
		}
	}
	
	@MainActor
	var systemImage: String {
		get {
			let colorBlindSytemImage: String
			switch self.location.type {
			case .system:
				colorBlindSytemImage = "circle.dotted"
			case .user:
				colorBlindSytemImage = SFSymbols.scopeIcon.rawValue
			}
			return AppStorageManager.shared.colorBlindMode ? colorBlindSytemImage : SFSymbols.busIcon.rawValue
		}
	}
	
	@MainActor
	var annotationView: MKAnnotationView {
		get {
			let markerAnnotationView = MKMarkerAnnotationView()
			markerAnnotationView.displayPriority = .required
			markerAnnotationView.canShowCallout = true
			#if canImport(AppKit)
			markerAnnotationView.markerTintColor = NSColor(self.tintColor)
			markerAnnotationView.glyphImage = NSImage(systemSymbolName: self.systemImage, accessibilityDescription: nil)
			#elseif canImport(UIKit) // canImport(AppKit)
			markerAnnotationView.markerTintColor = UIColor(self.tintColor)
			markerAnnotationView.glyphImage = UIImage(systemName: self.systemImage)
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
		#if os(iOS)
		let busID = await BoardBusManager.shared.busID
		let travelState = await BoardBusManager.shared.travelState
		#endif // os(iOS)
		do {
			return try await API.readBuses.perform(as: [Bus].self)
				.filter { (bus) in
					return abs(bus.location.date.timeIntervalSinceNow) < 300 // 5 minutes
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
		} catch {
			Logging.withLogger(for: .api) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to download buses: \(error, privacy: .public)")
			}
			return []
		}
	}
	
}
