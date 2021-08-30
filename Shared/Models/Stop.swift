//
//  Stop.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import MapKit

class Stop: NSObject, Identifiable, CustomAnnotation {
	
	let id: Int
	
	let coordinate: CLLocationCoordinate2D
	
	let name: String
	
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
		annotationView.canShowCallout = true
		#if os(macOS)
		annotationView.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)?.withTintColor(.white)
		annotationView.layer?.borderColor = .black
		annotationView.layer?.borderWidth = 2
		annotationView.layer?.cornerRadius = annotationView.frame.width / 2
		#else
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
	}()
	
	init(id: Int, coordinate: CLLocationCoordinate2D, name: String) {
		self.id = id
		self.coordinate = coordinate
		self.name = name
	}
	
}

extension Array where Element == Stop {
	
	static func download(_ stopsCallback: @escaping (_ stops: Self) -> Void) {
		let url = URL(string: "http://shuttles.rpi.edu/stops")!
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let data = data {
				var stops = self.init()
				try? (JSONSerialization.jsonObject(with: data) as? [[String: Any]])?.forEach { (rawStop) in
					guard let id = rawStop["id"] as? Int, let name = rawStop["name"] as? String, let latitude = rawStop["latitude"] as? Double, let longitude = rawStop["longitude"] as? Double else {
						return
					}
					let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
					DispatchQueue.main.sync {
						stops.append(Stop(id: id, coordinate: coordinate, name: name))
					}
				}
				stopsCallback(stops)
			}
		}
		task.resume()
	}
	
}
