//
//  Utilities.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import MapKit
import OSLog
import SwiftUI
import UserNotifications

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
		#endif
		
	}
	
	static var standardVisualEffectView: some View {
		#if canImport(AppKit)
		VisualEffectView(blendingMode: .withinWindow, material: .hudWindow)
		#elseif canImport(UIKit) // canImport(AppKit)
		VisualEffectView(UIBlurEffect(style: .systemMaterial))
		#endif // canImport(UIKit)
	}
	
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
	
	#if !os(macOS)
	static func sendToServer(coordinate: CLLocationCoordinate2D) async {
		guard let busID = await BoardBusManager.shared.busID, let locationID = await BoardBusManager.shared.locationID else {
			Logging.withLogger(for: .boardBus, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Required bus and location IDs not found while attempting to send location to server")
			}
			return
		}
		let location = Bus.Location(
			id: locationID,
			date: Date(),
			coordinate: coordinate.convertedToCoordinate(),
			type: .user
		)
		API.provider.request(.updateBus(id: busID, location: location)) { (_) in }
	}
	#endif // !os(macOS)
	
}

enum MapUtilities {
	
	enum Constants {
		
		static let originCoordinate = CLLocationCoordinate2D(latitude: 42.735, longitude: -73.688)
		
		static let mapRect = MKMapRect(
			origin: MKMapPoint(Constants.originCoordinate),
			size: MKMapSize(
				width: 10000,
				height: 10000
			)
		)
		
		#if canImport(AppKit)
		static let mapRectInsets = NSEdgeInsets(top: 100, left: 20, bottom: 20, right: 20)
		#elseif canImport(UIKit) // canImport(AppKit)
		static let mapRectInsets = UIEdgeInsets(top: 50, left: 10, bottom: 200, right: 10)
		#endif // canImport(UIKit)
		
	}
	
}

enum CalendarUtilities {
	
	static var isAprilFools: Bool {
		get {
			return Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: .now) == DateComponents(year: 2022, month: 4, day: 1)
		}
	}
	
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

extension JSONEncoder {
	
	convenience init(
		dateEncodingStrategy: DateEncodingStrategy = .deferredToDate,
		dataEncodingStrategy: DataEncodingStrategy = .base64,
		nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw
	) {
		self.init()
		self.keyEncodingStrategy = keyEncodingStrategy
		self.dateEncodingStrategy = dateEncodingStrategy
		self.dataEncodingStrategy = dataEncodingStrategy
		self.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
	}
	
}

extension JSONDecoder {
	
	convenience init(
		dateDecodingStrategy: DateDecodingStrategy = .deferredToDate,
		dataDecodingStrategy: DataDecodingStrategy = .base64,
		nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw
	) {
		self.init()
		self.keyDecodingStrategy = keyDecodingStrategy
		self.dateDecodingStrategy = dateDecodingStrategy
		self.dataDecodingStrategy = dataDecodingStrategy
		self.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
	}
	
}

extension Bundle {
	
	var version: String? {
		get {
			return self.infoDictionary?["CFBundleShortVersionString"] as? String
		}
	}
	
	var build: String? {
		get {
			return self.infoDictionary?["CFBundleVersion"] as? String
		}
	}
	
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

@available(iOS, introduced: 15, deprecated: 16)
@available(macOS, introduced: 12, deprecated: 13)
extension URL {
	
	struct CompatibilityFormatStyle: ParseableFormatStyle {
		
		struct ParseStrategy: Foundation.ParseStrategy {
			
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
		
		var parseStrategy = ParseStrategy()
		
		func format(_ value: URL) -> String {
			return value.absoluteString
		}
		
	}
	
}

@available(iOS, introduced: 15, deprecated: 16)
@available(macOS, introduced: 12, deprecated: 13)
extension ParseableFormatStyle where Self == URL.CompatibilityFormatStyle {
	
	static var compatibilityURL: Self {
		get {
			return Self()
		}
	}
	
}

extension Set: RawRepresentable where Element == UUID {
	
	public var rawValue: String {
		get {
			var string = "["
			for element in self {
				string += element.uuidString + ","
			}
			string.removeLast()
			string += "]"
			return string
		}
	}
	
	public init?(rawValue: String) {
		self.init()
		var string = rawValue
		guard string.first == "[", string.last == "]" else {
			return nil
		}
		string.removeFirst()
		string.removeLast()
		for component in string.split(separator: ",") {
			guard let element = UUID(uuidString: String(component)) else {
				return nil
			}
			self.insert(element)
		}
	}
	
}

#if canImport(UIKit)
extension UIKeyboardType {
	
	static let url: Self = .URL
	
}
#endif // canImport(UIKit)

#if canImport(AppKit)
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
#endif // canImport(AppKit)
