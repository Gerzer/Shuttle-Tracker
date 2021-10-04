//
//  Stop.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import MapKit

class Stop: NSObject, Decodable, Identifiable, CustomAnnotation {
	
	enum CodingKeys: String, CodingKey {
		
		case name
		case coordinate
		
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
		#endif // os(macOS)
		return annotationView
	}()
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.coordinate = try container.decode(Coordinate.self, forKey: .coordinate).convertedForCoreLocation()
	}
	
}

extension Array where Element == Stop {
	
	static func download(_ stopsCallback: @escaping (_ stops: Self) -> Void) {
		API.provider.request(.readStops) { (result) in
			let stops = try? result.value?.map([Stop].self)
			stopsCallback(stops ?? [])
		}
	}
	
}
