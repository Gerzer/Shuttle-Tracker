//
//  Stop.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import MapKit

// TODO: Revert changes in the same commit as this comment because they’re not actually needed
class Stop: NSObject, Codable, Identifiable, CustomAnnotation {
	
	enum CodingKeys: String, CodingKey {
		
		case name, coordinate
		
	}
	
	let name: String
	
	let coordinate: CLLocationCoordinate2D
	
	var location: CLLocation {
		get {
			return CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
		}
	}
	
	var title: String? {
		get {
			return self.name
		}
	}
	
	let annotationView: MKAnnotationView = {
		
		func annotationViewFactory() -> MKAnnotationView {
			let annotationView = MKAnnotationView()
			annotationView.displayPriority = .defaultHigh
			annotationView.canShowCallout = true
			#if os(macOS)
			annotationView.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)?
				.withTintColor(.white)
			annotationView.layer?.borderColor = .black
			annotationView.layer?.borderWidth = 2
			annotationView.layer?.cornerRadius = annotationView.frame.width / 2
			#else // os(macOS)
			let image = UIImage(systemName: "circle.fill")!
			let imageView = UIImageView(image: image)
			imageView.tintColor = .white
			imageView.layer.borderColor = UIColor.black.cgColor
			imageView.layer.borderWidth = 2
			imageView.layer.cornerRadius = imageView.frame.width / 2
			imageView.frame = imageView.frame.offsetBy(dx: imageView.frame.width / -2, dy: imageView.frame.height / -2)
			annotationView.addSubview(imageView)
			#endif
			return annotationView
		}
		
		if Thread.isMainThread {
			return annotationViewFactory()
		} else {
			// Synchronously hop to the main thread because ActivityKit might initiatlize this property on a background thread, which the MKAnnotationView initializer doesn’t appreciate
			return DispatchQueue.main.sync(execute: annotationViewFactory)
		}
	}()
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.coordinate = try container.decode(Coordinate.self, forKey: .coordinate)
			.convertedForCoreLocation()
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.name, forKey: .name)
		try container.encode(
			self.coordinate.convertedToCoordinate(),
			forKey: .coordinate
		)
	}
	
}

#if !WIDGET
extension Array where Element == Stop {
	
	static func download(_ stopsCallback: @escaping (_ stops: Self) -> Void) {
		API.provider.request(.readStops) { (result) in
			let stops = try? result
				.get()
				.map([Stop].self)
			stopsCallback(stops ?? [])
		}
	}
	
}
#endif // !WIDGET
