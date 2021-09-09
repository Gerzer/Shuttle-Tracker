//
//  Utilities.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit

enum ViewUtilities {
	
	enum Toast {
		
		#if os(macOS)
		static let closeButtonDimension: CGFloat = 15

		static let cornerRadius: CGFloat = 10
		#else // os(macOS)
		static let closeButtonDimension: CGFloat = 25

		static let cornerRadius: CGFloat = 30
		#endif // os(macOS)
		
	}
	
	#if os(macOS)
	static var standardVisualEffectView: some View {
		VisualEffectView(blendingMode: .withinWindow, material: .hudWindow)
	}
	#else // os(macOS)
	static var standardVisualEffectView: some View {
		VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
	}
	#endif // os(macOS)
	
}

enum LocationUtilities {
	
	private static let locationManagerDelegate = LocationManagerDelegate()
	
	private(set) static var locationManager: CLLocationManager = {
		let locationManager = CLLocationManager()
		#if os(macOS) || APPCLIP
		locationManager.requestWhenInUseAuthorization()
		#else
		locationManager.requestAlwaysAuthorization()
		#endif
		locationManager.startUpdatingLocation()
		return locationManager
	}() {
		didSet {
			self.locationManager.delegate = self.locationManagerDelegate
		}
	}
	
}

enum MapUtilities {
	
	static let originCoordinate = CLLocationCoordinate2D(latitude: 42.735, longitude: -73.688)
	
	static var mapRect: MKMapRect {
		get {
			let origin = MKMapPoint(self.originCoordinate)
			let size = MKMapSize(width: 10000, height: 10000)
			return MKMapRect(origin: origin, size: size)
		}
	}
	
}

enum DefaultsKeys {
	
	static let coldLaunchCount = "ColdLaunchCount"
	
}

enum TravelState {
	
	case onBus
	case notOnBus
	
}

protocol IdentifiableByHashValue: Identifiable, Hashable { }

extension IdentifiableByHashValue {
	
	var id: Int {
		get {
			return self.hashValue
		}
	}
	
}

extension CLLocationCoordinate2D: Equatable {
	
	public static func == (_ leftCoordinate: CLLocationCoordinate2D, _ rightCoordinate: CLLocationCoordinate2D) -> Bool {
		return leftCoordinate.latitude == rightCoordinate.latitude && leftCoordinate.longitude == rightCoordinate.longitude
	}
	
}

extension MKMapPoint: Equatable {
	
	init(_ coordinate: Coordinate) {
		self.init(coordinate.convertedForCoreLocation())
	}
	
	public static func == (_ leftMapPoint: MKMapPoint, _ rightMapPoint: MKMapPoint) -> Bool {
		return leftMapPoint.coordinate == rightMapPoint.coordinate
	}
	
}

extension Set {
	
	static func generateUnion(of sets: [Set]) -> Set {
		var newSet = Set()
		sets.forEach { (set) in
			newSet.formUnion(set)
		}
		return newSet
	}
	
}

#if os(macOS)
extension NSImage {
	
	func withTintColor(_ color: NSColor) -> NSImage {
		let image = self.copy() as! NSImage
		image.lockFocus()
		color.set()
		let imageRect = NSRect(origin: .zero, size: image.size)
		imageRect.fill(using: .sourceAtop)
		image.unlockFocus()
		return image
	}
	
}
#endif
