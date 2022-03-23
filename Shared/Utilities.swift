//
//  Utilities.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import SwiftUI
import MapKit
import UserNotifications
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
	
	private static var locationManagerHandlers: [(CLLocationManager) -> Void] = []
	
	static var locationManager: CLLocationManager! {
		didSet {
			self.locationManager.delegate = self.locationManagerDelegate
			for locationManagerHandler in self.locationManagerHandlers {
				locationManagerHandler(self.locationManager)
			}
		}
	}
	
	static func registerLocationManagerHandler(_ handler: @escaping (CLLocationManager) -> Void) {
		self.locationManagerHandlers.append(handler)
	}
	
	static func sendToServer(coordinate: CLLocationCoordinate2D) {
		guard let busID = MapState.shared.busID, let locationID = MapState.shared.locationID else {
			LoggingUtilities.logger.log(level: .fault, "Required bus and location identifiers not found")
			return
		}
		let location = Bus.Location(id: locationID, date: Date(), coordinate: coordinate.convertedToCoordinate(), type: .user)
		API.provider.request(.updateBus(busID, location: location)) { (_) in
			return
		}
	}
	
}

enum MapUtilities {
	
	enum Constants {
		
		static let originCoordinate = CLLocationCoordinate2D(latitude: 42.735, longitude: -73.688)
		
	}
	
	static let mapRect = MKMapRect(
		origin: MKMapPoint(Constants.originCoordinate),
		size: MKMapSize(
			width: 10000,
			height: 10000
		)
	)
	
}

enum CalendarUtilities {
	
	@available(iOS 15, macOS 12, *) static var isAprilFools: Bool {
		get {
			return Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: .now) == DateComponents(year: 2022, month: 4, day: 1)
		}
	}
	
}

enum LoggingUtilities {
	
	static let logger = Logger()
	
}

enum UserNotificationUtilities {
	
	static func requestAuthorization() async throws {
		try await UNUserNotificationCenter
			.current()
			.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
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
	
	public static func == (_ left: CLLocationCoordinate2D, _ right: CLLocationCoordinate2D) -> Bool {
		return left.latitude == right.latitude && left.longitude == right.longitude
	}
	
	func convertedToCoordinate() -> Coordinate {
		return Coordinate(latitude: self.latitude, longitude: self.longitude)
	}
	
}

extension MKMapPoint: Equatable {
	
	init(_ coordinate: Coordinate) {
		self.init(coordinate.convertedForCoreLocation())
	}
	
	public static func == (_ left: MKMapPoint, _ right: MKMapPoint) -> Bool {
		return left.coordinate == right.coordinate
	}
	
}

extension Notification.Name {
	
	static let refreshBuses = Notification.Name("RefreshBuses")
	
}

extension View {
	
	func innerShadow<S: Shape>(using shape: S, color: Color = .black, width: CGFloat = 5) -> some View {
		let offsetFactor = CGFloat(cos(0 - Float.pi / 2)) * 0.6 * width
		return self.overlay(
			shape
				.stroke(color, lineWidth: width)
				.offset(x: offsetFactor, y: offsetFactor)
				.blur(radius: width)
				.mask(shape)
		)
	}
	
	func rainbow() -> some View {
		return self
			.overlay(
				GeometryReader { (geometry) in
					ZStack {
						LinearGradient(
							gradient: Gradient(
								colors: stride(from: 0.7, to: 0.85, by: 0.01)
									.map { (hue) in
										return Color(hue: hue, saturation: 1, brightness: 1)
									}
							),
							startPoint: .leading,
							endPoint: .trailing
						)
						.frame(width: geometry.size.width)
					}
				}
			)
			.mask(self)
	}
	
}

extension URL {
	
	struct FormatStyle: ParseableFormatStyle {
		
		struct Strategy: ParseStrategy {
			
			enum ParseError: Error {
				
				case parseFailed
				
			}
			
			func parse(_ value: String) throws -> URL {
				guard let url = URL(string: value) else {
					throw ParseError.parseFailed
				}
				return url
			}
			
		}
		
		var parseStrategy = Strategy()
		
		func format(_ value: URL) -> String {
			return value.absoluteString
		}
		
	}
	
}

@available(iOS 15, macOS 12, *) extension ParseableFormatStyle where Self == URL.FormatStyle {
	
	static var url: URL.FormatStyle {
		get {
			return URL.FormatStyle()
		}
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
