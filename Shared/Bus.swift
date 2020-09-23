//
//  Bus.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit

class Bus: NSObject, Codable {
	
	struct Location: Codable {
		
		struct Coordinate: Codable {
			
			var latitude: Double
			var longitude: Double
			
		}
		
		var id: UUID
		var date: Date
		var coordinate: Coordinate
		
	}
	
	let id: Int
	var location: Location
	
	init(id: Int, location: Location) {
		self.id = id
		self.location = location
	}
	
	static func == (_ leftBus: Bus, _ rightBus: Bus) -> Bool {
		return leftBus.id == rightBus.id
	}
	
}

extension Bus: CustomAnnotation {
	
	var annotationView: MKAnnotationView {
		get {
			let markerAnnotationView = MKMarkerAnnotationView()
			markerAnnotationView.displayPriority = .required
			#if os(macOS)
			markerAnnotationView.glyphImage = NSImage(systemSymbolName: "bus", accessibilityDescription: nil)
			#else
			markerAnnotationView.glyphImage = UIImage(systemName: "bus")
			#endif
			return markerAnnotationView
		}
	}
	
}

extension Bus: MKAnnotation {
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return self.location.coordinate.convertForCoreLocation()
		}
	}
	
	var subtitle: String? {
		get {
			return "Bus \(self.id)"
		}
	}
	
}

extension Bus.Location {
	
	func convertForCoreLocation() -> CLLocation {
		return CLLocation(coordinate: self.coordinate.convertForCoreLocation(), altitude: .nan, horizontalAccuracy: .nan, verticalAccuracy: .nan, timestamp: self.date)
	}
	
}

extension Bus.Location.Coordinate {
	
	func convertForCoreLocation() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}
	
}

extension CLLocationCoordinate2D {
	
	func convertToBusCoordinate() -> Bus.Location.Coordinate {
		return Bus.Location.Coordinate(latitude: self.latitude, longitude: self.longitude)
	}
	
}

extension Array where Element == Bus {
	
	static func download(_ busesCallback:  @escaping (_ buses: [Bus]) -> Void) {
		let url = URL(string: "https://shuttle.gerzer.software/buses")!
		let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
			guard let data = data else {
				return
			}
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			if let buses = try? decoder.decode(self, from: data) {
				busesCallback(buses)
			}
		}
		task.resume()
	}
	
}
