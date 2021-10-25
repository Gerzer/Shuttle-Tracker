//
//  Utilities.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit
import OSLog

enum ViewUtilities {
	
	enum Constants {
		
		#if os(macOS)
		static let sheetCloseButtonDimension: CGFloat = 15
		
		static let toastCloseButtonDimension: CGFloat = 15

		static let toastCornerRadius: CGFloat = 10
		#else // os(macOS)
		static let sheetCloseButtonDimension: CGFloat = 30
		
		static let toastCloseButtonDimension: CGFloat = 25

		static let toastCornerRadius: CGFloat = 30
		#endif // os(macOS)
		
	}
	
	#if os(macOS)
	static var standardVisualEffectView: some View {
		VisualEffectView(blendingMode: .withinWindow, material: .hudWindow)
	}
	#else // os(macOS)
	static var standardVisualEffectView: some View {
		VisualEffectView(UIBlurEffect(style: .systemMaterial))
	}
	#endif // os(macOS)
	
}

enum LocationUtilities {
	
	private static let locationManagerDelegate = LocationManagerDelegate()
	
	static var locationManager: CLLocationManager! {
		didSet {
			self.locationManager.delegate = self.locationManagerDelegate
		}
	}
	
	static func sendToServer(coordinate: CLLocationCoordinate2D) {
		guard let busID = MapState.sharedInstance.busID, let locationID = MapState.sharedInstance.locationID else {
			LoggingUtilities.logger.log(level: .fault, "Required bus and location identifiers not found")
			return
		}
		let location = Bus.Location(id: locationID, date: Date(), coordinate: coordinate.convertedToCoordinate(), type: .user)
		API.provider.request(.updateBus(busID, location: location)) { (_) in
			return
		}
	}
	
	static func leaveBus() {
		DispatchQueue.main.async {
			MapState.sharedInstance.busID = nil
			MapState.sharedInstance.locationID = nil
			MapState.sharedInstance.travelState = .notOnBus
			ViewState.sharedInstance.statusText = .thanks
			DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
				ViewState.sharedInstance.statusText = .mapRefresh
			}
		}
		LocationUtilities.locationManager.stopUpdatingLocation()
	}
	
}

enum MapUtilities {
	
	enum Constants {
		
		static let originCoordinate = CLLocationCoordinate2D(latitude: 42.735, longitude: -73.688)
		
	}
	
	static var mapRect: MKMapRect {
		get {
			let origin = MKMapPoint(Constants.originCoordinate)
			let size = MKMapSize(width: 10000, height: 10000)
			return MKMapRect(origin: origin, size: size)
		}
	}
	
}

enum NotificationUtilities {
	
	enum Constants {
		
		static let leaveBusActionIdentifier = "LeaveBus"
		
		static let longTripCategoryIdentifier = "LongTrip"
		
	}
	
	static let userNotificationCenterDelegate: UNUserNotificationCenterDelegate = {
		if #available(iOS 15, *) {
			return UserNotificationCenterDelegate()
		} else {
			return LegacyUserNotificationCenterDelegate()
		}
	}()
	
}

enum LoggingUtilities {
	
	static let logger = Logger()
	
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

extension UNUserNotificationCenter {
	
	static var current: UNUserNotificationCenter {
		get {
			return self.current()
		}
	}
	
}

extension UNMutableNotificationContent {
	
	convenience init(title: String, subtitle: String = "", body: String, badge: NSNumber? = nil, sound: UNNotificationSound? = nil, launchImageName: String = "", userInfo: [AnyHashable: Any] = [:], attachments: [UNNotificationAttachment] = [], categoryIdentifier: String = "", threadIdentifier: String = "", targetContentIdentifier: String? = nil) {
		self.init()
		self.title = title
		self.subtitle = subtitle
		self.body = body
		self.badge = badge
		self.sound = sound
		self.launchImageName = launchImageName
		self.userInfo = userInfo
		self.attachments = attachments
		self.categoryIdentifier = categoryIdentifier
		self.threadIdentifier = threadIdentifier
		self.targetContentIdentifier = targetContentIdentifier
	}
	
	@available(iOS 15, *) convenience init(title: String, subtitle: String = "", body: String, badge: NSNumber? = nil, sound: UNNotificationSound? = nil, launchImageName: String = "", userInfo: [AnyHashable: Any] = [:], attachments: [UNNotificationAttachment] = [], categoryIdentifier: String = "", threadIdentifier: String = "", targetContentIdentifier: String? = nil, interruptionLevel: UNNotificationInterruptionLevel = .active, relevanceScore: Double = 0) {
		self.init(
			title: title,
			subtitle: subtitle,
			body: body,
			badge: badge,
			sound: sound,
			launchImageName: launchImageName,
			userInfo: userInfo,
			attachments: attachments,
			categoryIdentifier: categoryIdentifier,
			threadIdentifier: threadIdentifier,
			targetContentIdentifier: targetContentIdentifier
		)
		self.interruptionLevel = interruptionLevel
		self.relevanceScore = relevanceScore
	}
	
}

extension Notification.Name {
	
	static let refreshBuses = Notification.Name("RefreshBuses")
	
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

extension View {
	
	func innerShadow<S: Shape>(using shape: S, color: Color = .black, width: CGFloat = 5) -> some View {
		let offsetFactor = CGFloat(cos(0 - Float.pi / 2)) * 0.6 * width
		return self
			.overlay(
				shape
					.stroke(color, lineWidth: width)
					.offset(x: offsetFactor, y: offsetFactor)
					.blur(radius: width)
					.mask(shape)
			)
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
#endif // os(macOS)
