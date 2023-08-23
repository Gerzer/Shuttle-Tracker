//
//  MapCameraPositionWrapper.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 8/23/23.
//

import MapKit
import SwiftUI

struct MapCameraPositionWrapper {
	
	private var storage: Any?
	
	@available(iOS 17, macOS 14, *)
	var mapCameraPosition: MapCameraPosition {
		get {
			return self.storage! as! MapCameraPosition
		}
		set {
			self.storage = newValue
		}
	}
	
	@available(iOS, deprecated: 17)
	@available(macOS, deprecated: 14)
	private init() {
		self.storage = nil
	}
	
	@available(iOS 17, macOS 14, *)
	init(_ mapCameraPosition: MapCameraPosition) {
		self.storage = mapCameraPosition
	}
	
	static let `default`: MapCameraPositionWrapper = {
		if #available(iOS 17, macOS 14, *) {
			return MapCameraPositionWrapper(MapConstants.defaultCameraPosition)
		} else {
			return MapCameraPositionWrapper()
		}
	}()
	
}
