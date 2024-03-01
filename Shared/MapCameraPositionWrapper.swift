//
//  MapCameraPositionWrapper.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 8/23/23.
//

import MapKit
import SwiftUI

/// A wrapper type for `MapCameraPosition` from MapKit that enables its use safely as a stored property in other types, even when backported before iOS 17 or macOS 14.
///
/// Use the ``mapCameraPosition`` property to access the underlying `MapCameraPosition` instance. The property is available only on supported OS versions, which is enforced at buildtime. On older OS versions, wrapper instance contain inaccessible null data.
struct MapCameraPositionWrapper {
	
	private var storage: Any?
	
	/// The underlying map camera position.
	@available(iOS 17, macOS 14, *)
	var mapCameraPosition: MapCameraPosition {
		get {
			return self.storage! as! MapCameraPosition
		}
		set {
			self.storage = newValue
		}
	}
	
	/// Creates a null map camera position wrapper.
	///
	/// - Warning: Don’t call this initializer on OS versions that support `MapCameraPosition`; doing so will result in an invalid instance, potentially causing fatal crashes.
	@available(iOS, deprecated: 17)
	@available(macOS, deprecated: 14)
	private init() {
		self.storage = nil
	}
	
	/// Creates a map camera position wrapper.
	/// - Parameter mapCameraPosition: The underlying map camera position.
	@available(iOS 17, macOS 14, *)
	init(_ mapCameraPosition: MapCameraPosition) {
		self.storage = mapCameraPosition
	}
	
	/// The default map camera position wrapper.
	///
	/// On supported OS versions, the wrapper instance is initialized to wrap ``MapConstants/defaultCameraPosition``. On unsupported OS versions, the instance is initialized with inaccessible null data.
	static let `default`: MapCameraPositionWrapper = {
		if #available(iOS 17, macOS 14, *) {
			return MapCameraPositionWrapper(MapConstants.defaultCameraPosition)
		} else {
			return MapCameraPositionWrapper()
		}
	}()
	
}
