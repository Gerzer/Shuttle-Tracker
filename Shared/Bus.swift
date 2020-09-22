//
//  Bus.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit

class Bus: NSObject, Identifiable {
	
	let id: Int
	var coordinate: CLLocationCoordinate2D
	
	
	init(id: Int, coordinate: CLLocationCoordinate2D) {
		self.id = id
		self.coordinate = coordinate
	}
	
}

extension Bus: CustomAnnotation {
	
	var annotationView: MKAnnotationView {
		get {
			let markerAnnotationView = MKMarkerAnnotationView(annotation: self, reuseIdentifier: nil)
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
	
	var subtitle: String? {
		get {
			return "Bus \(self.id)"
		}
	}
	
}

extension Set where Element == Bus {
	
	static func download(_ busCallback:  @escaping (_ bus: Bus) -> Void) {
		let url = URL(string: "https://shuttles.rpi.edu/datafeed")!
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let data = data, let rawString = String(data: data, encoding: .utf8) {
				rawString.split(separator: "\r\n").dropFirst().dropLast().forEach { (rawLine) in
					guard let idRange = rawLine.range(of: #"(?<=(Vehicle\sID:))\d+"#, options: [.regularExpression]), let id = Int(rawLine[idRange]) else {
						return
					}
					guard let latitudeRange = rawLine.range(of: #"(?<=(lat:))-?\d+\.\d+"#, options: [.regularExpression]), let latitude = Double(rawLine[latitudeRange]) else {
						return
					}
					guard let longitudeRange = rawLine.range(of: #"(?<=(lon:))-?\d+\.\d+"#, options: [.regularExpression]), let longitude = Double(rawLine[longitudeRange]) else {
						return
					}
					let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
					busCallback(Bus(id: id, coordinate: coordinate))
				}
			}
		}
		task.resume()
	}
	
}
