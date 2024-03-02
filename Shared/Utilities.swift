//
//  Utilities.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import HTTPStatus
import MapKit
import STLogging
import SwiftUI
import UserNotifications

enum ViewConstants {
		
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

extension VisualEffectView {
	
	/// The standard visual-effect view, which is optimized for the current context.
	static var standard: VisualEffectView {
		get {
			#if canImport(AppKit)
			return VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
			#elseif canImport(UIKit) // canImport(AppKit)
			return VisualEffectView(UIBlurEffect(style: .systemMaterial))
			#endif // canImport(UIKit)
		}
	}
	
}

enum LocationUtilities {
	
	#if !os(macOS)
	static func sendToServer(coordinate: CLLocationCoordinate2D) async {
		guard let busID = await BoardBusManager.shared.busID, let locationID = await BoardBusManager.shared.locationID else {
			#log(system: Logging.system, category: .boardBus, level: .error, doUpload: true, "Required bus and location IDs not found while attempting to send location to server")
			return
		}
		let location = Bus.Location(
			id: locationID,
			date: .now,
			coordinate: coordinate.convertedToCoordinate(),
			type: .user
		)
		
		let tolerance = await AppStorageManager.shared.routeTolerance
		if await MapState.shared.distance(to: coordinate) > Double(tolerance) {
			switch BoardBusManager.globalTravelState {
			case .onBus:
				await BoardBusManager.shared.leaveBus(manual: false)
			default:
				#log(system: Logging.system, category: .boardBus, doUpload: true, "Board Bus is unexpectedly inactive while checking route tolerance.")
			}
		} else {
			do {
				let resolvedBus = try await API.updateBus(id: busID, location: location).perform(as: Bus.self)
				await BoardBusManager.shared.updateBusID(with: resolvedBus)
			} catch let error as any HTTPStatusCode {
				if let clientError = error as? HTTPStatusCodes.ClientError, clientError == HTTPStatusCodes.ClientError.conflict {
					return
				}
				#log(system: Logging.system, category: .api, level: .error, "Failed to send location to server: \(error.message, privacy: .public)")
			} catch {
				#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to send location to server: \(error, privacy: .public)")
			}
		}
	}
	#endif // !os(macOS)
	
}

enum DefaultsKeys {
	
	static let coldLaunchCount = "ColdLaunchCount"
	
}

enum MapConstants {
	
	static let originCoordinate = CLLocationCoordinate2D(latitude: 42.735, longitude: -73.688)
	
	static let mapRect = MKMapRect(
		origin: MKMapPoint(MapConstants.originCoordinate),
		size: MKMapSize(
			width: 10000,
			height: 10000
		)
	)
	
	static let earthRadius = 6378.137;
	
	@available(iOS 17, macOS 14, *)
	static let defaultCameraPosition: MapCameraPosition = .rect(MapConstants.mapRect)
	
	#if canImport(AppKit)
	static let mapRectInsets = NSEdgeInsets(top: 100, left: 20, bottom: 20, right: 20)
	#elseif canImport(UIKit) // canImport(AppKit)
	static let mapRectInsets = UIEdgeInsets(top: 50, left: 10, bottom: 200, right: 10)
	#endif // canImport(UIKit)
	
}

enum UserLocationError: LocalizedError {
	
	case unavailable
	
	var errorDescription: String? {
		get {
			switch self {
			case .unavailable:
				return "The user’s location is unavailable."
			}
		}
	}
	
}

extension CLLocationManager {
	
	private static var handlers: [(CLLocationManager) -> Void] = []
	
	/// The default location manager.
	/// - Important: This property is set to `nil` by default, and references to it will crash. The app **must** set a concrete value immediately upon launch.
	static var `default`: CLLocationManager! {
		get {
			if self.defaultStorage == nil {
				#log(system: Logging.system, category: .location, level: .error, doUpload: true, "The default location manager was referenced, but no value is set. This is a fatal programmer error!")
			}
			return self.defaultStorage
		}
		set {
			newValue.delegate = .default
			for handler in self.handlers {
				handler(newValue)
			}
			self.defaultStorage = newValue
		}
	}
	
	private static var defaultStorage: CLLocationManager?
	
	/// Register a handler to be invoked whenever a new default location manager is set.
	///
	/// Handlers are invoked in the order in which they were registered. This means that a later handler could potentially undo or overwrite modifications to the location manager that were performed by an earlier handler.
	/// - Parameter handler: The handler to invoke with the new value.
	static func registerHandler(_ handler: @escaping (CLLocationManager) -> Void) {
		self.handlers.append(handler)
	}
	
}

extension CLLocationCoordinate2D: Equatable {
	
	public static func == (_ left: CLLocationCoordinate2D, _ right: CLLocationCoordinate2D) -> Bool {
		return left.latitude == right.latitude && left.longitude == right.longitude
	}
	
	func convertedToCoordinate() -> Coordinate {
		return Coordinate(latitude: self.latitude, longitude: self.longitude)
	}
	
	func asCartesian() -> (x: Double, y: Double, z: Double) {
		return (
			x: MapConstants.earthRadius * cos(self.latitude * .pi / 180) * cos(self.longitude * .pi / 180),
			y: MapConstants.earthRadius * cos(self.latitude * .pi / 180) * sin(self.longitude * .pi / 180),
			z: MapConstants.earthRadius * sin(self.latitude * .pi / 180)
		)
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

extension UNUserNotificationCenter {
	
	/// Requests notification authorization with default options.
	///
	/// Provisional authorization for alerts, sounds, and badges is requested.
	static func requestDefaultAuthorization() async throws {
		try await UNUserNotificationCenter
			.current()
			.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
	}
	
	/// Updates the app’s badge on the Home Screen or in the Dock.
	///
	/// This method downloads the latest announcements from the server. The count of active announcements that the user has not yet viewed is set as the badge number and published to the rest of the app via ``ViewState/badgeNumber``.
	static func updateBadge() async throws {
		let viewedAnnouncementIDs = await AppStorageManager.shared.viewedAnnouncementIDs
		let announcementsCount = await [Announcement]
			.download()
			.filter { (announcement) in
				return !viewedAnnouncementIDs.contains(announcement.id)
			}
			.count
		await MainActor.run {
			ViewState.shared.badgeNumber = announcementsCount
		}
		if #available(iOS 16, macOS 13, *) {
			try await UNUserNotificationCenter.current().setBadgeCount(announcementsCount)
		} else {
			#if canImport(AppKit)
			await MainActor.run {
				NSApplication.shared.dockTile.badgeLabel = announcementsCount > 0 ? "\(announcementsCount)" : nil
			}
			#elseif canImport(UIKit) // canImport(AppKit)
			await MainActor.run {
				UIApplication.shared.applicationIconBadgeNumber = announcementsCount
			}
			#endif // canImport(UIKit)
		}
	}
	
	/// Processes a new notification.
	/// - Parameter userInfo: The notification’s payload.
	static func handleNotification(userInfo: [AnyHashable: Any]? = nil) async {
		Task { // Dispatch a new task because we don’t need to await the result
			do {
				try await self.updateBadge()
			} catch {
				#log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Failed to update badge: \(error, privacy: .public)")
			}
		}
		#if os(iOS)
		let sheetStack = ShuttleTrackerApp.sheetStack
		#elseif os(macOS) // os(iOS)
		let sheetStack = ShuttleTrackerApp.contentViewSheetStack
		#endif // os(macOS)
		if await sheetStack.top == nil {
			#log(system: Logging.system, category: .apns, level: .debug, "Attempting to push a sheet in response to a notification")
			if let userInfo {
				if JSONSerialization.isValidJSONObject(userInfo) {
					do {
						let data = try JSONSerialization.data(withJSONObject: userInfo)
						let announcement = try JSONDecoder().decode(Announcement.self, from: data)
						await sheetStack.push(.announcement(announcement))
					} catch {
						#log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Failed to decode the notification payload as an announcement: \(error, privacy: .public)")
					}
				} else {
					#log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Notification payload can’t be converted to JSON")
				}
			}
		} else {
			#log(system: Logging.system, category: .apns, level: .debug, "Refusing to push a sheet in response to a notification because the sheet stack is nonempty")
		}
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
	
	/// A URL format style that can be backported before the introduction of the official format style.
	struct CompatibilityFormatStyle: ParseableFormatStyle {
		
		struct ParseStrategy: Foundation.ParseStrategy {
			
			enum ParseError: LocalizedError {
				
				case parseFailed
				
				var errorDescription: String? {
					get {
						switch self {
						case .parseFailed:
							return "URL parsing failed."
						}
					}
				}
				
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

extension UUID: RawRepresentable {
	
	public var rawValue: String {
		get {
			return self.uuidString
		}
	}
	
	public init?(rawValue: String) {
		self.init(uuidString: rawValue)
	}
	
}

// TODO: Find a different way to persist sets of UUIDs in User Defaults because this code is fragile and might break if the standard library ever evolves to include its own conformance of Set to RawRepresentable or if UUID’s uuidString implementation in Foundation ever changes
// To maintain syntactic consistency with the array literal (from which a set can be initialized), the raw value is represented as a comma-separated list of UUID strings with “[” and “]” as the first and last characters, respectively, of the overall string. This list is sorted by the natural ordering of the UUID strings to achieve determinism and the ability to compare equivalent raw values directly. The format of the individual UUIDs is deferred to the UUID structure and is assumed to be consistent and deterministic. Note that unlike array-of-string literals, quotation marks are not included in the raw value.
extension Set: RawRepresentable where Element == UUID {
	
	public var rawValue: String {
		get {
			var string = "["
			let sorted = self.sorted { (first, second) in
				return first.uuidString < second.uuidString
			}
			for element in sorted {
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

func * (
	lhs: (x: Double, y: Double, z: Double),
	rhs: (x: Double, y: Double, z: Double)
) -> (x: Double, y: Double, z: Double) {
	return (
		x: lhs.y * rhs.z - lhs.z * rhs.y,
		y: lhs.z * rhs.x - lhs.x * rhs.z,
		z: lhs.x * rhs.y - lhs.y * rhs.x
	)
}

#if canImport(UIKit)
extension UIKeyboardType {
	
	/// A keyboard type that’s optimized for URL entry.
	///
	/// This static property is the same as the `UIKeyboardType.URL` enumeration case, but unlike the enumeration case, it follows standard Swift naming conventions.
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
