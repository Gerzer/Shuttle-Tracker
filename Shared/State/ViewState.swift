//
//  ViewState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import Combine
import HTTPStatus
import OnboardingKit
import SwiftUI

@MainActor
final class ViewState: OnboardingFlags {
	
	final class Handles {
		
		var tripCount: OnboardingConditions.ManualCounter.Handle?
		
		var whatsNew: OnboardingConditions.ManualCounter.Handle?
		
	}
	
	enum AlertType: Identifiable {
		
		case noNearbyStop, updateAvailable, serverUnavailable
		
		var id: Self {
			get {
				return self
			}
		}
		
	}
	
	enum ToastType: Equatable, Hashable, Identifiable {
		
		case legend, boardBus, network
		
		var id: Self {
			get {
				return self
			}
		}
		
		func hash(into hasher: inout Hasher) {
			switch self {
			case .legend:
				hasher.combine("legend")
			case .boardBus:
				hasher.combine("boardBus")
			case .debugMode(let statusCode):
				hasher.combine("debugMode")
				hasher.combine(statusCode)
			}
		}
		
		static func == (lhs: Self, rhs: Self) -> Bool {
			switch lhs {
			case .legend:
				// Use an explicit switch statement to avoid infinite recursion
				switch rhs {
				case .legend:
					return true
				default:
					return false
				}
			case .boardBus:
				// Use an explicit switch statement to avoid infinite recursion
				switch rhs {
				case .boardBus:
					return true
				default:
					return false
				}
			case .debugMode(let lhsStatusCode):
				if case .debugMode(let rhsStatusCode) = rhs {
					return lhsStatusCode.rawValue == rhsStatusCode.rawValue
				} else {
					return false
				}
			}
		}
		
	}
	
	enum StatusText {
		
		case mapRefresh, locationData, thanks
		
		var string: String {
			get {
				switch self {
				case .mapRefresh:
					return "The map automatically refreshes every 5 seconds."
				case .locationData:
					return "You’re helping other users with real-time bus location data."
				case .thanks:
					return "Thanks for helping other users with real-time bus location data!"
				}
			}
		}
		
	}
	
	static let shared = ViewState()
	
	@Published
	var alertType: AlertType?
	
	@Published
	var toastType: ToastType?
	
	@Published
	var statusText = StatusText.mapRefresh
	
    #if !os(watchOS)
	@Published
	var legendToastHeadlineText: LegendToast.HeadlineText?
    #endif
	
	/// The number that should be displayed in notification badges.
	///
	/// Generally, the value of this property should be the count of announcements that the user has not yet viewed.
	/// - Warning: Don’t set this property directly; instead, use `updateBadge()` on `UNUserNotificationCenter`.
	@Published
	var badgeNumber = 0
	
	let handles = Handles()
	
	// TODO: Simplify to a single stored property when we drop support for iOS 15 and macOS 12
	// We have to do this annoying dance with a separate refreshSequenceStorage backing because Swift doesn’t yet support gating stored properties on API availability.
	
	@available(iOS 16, macOS 13, *)
	var refreshSequence: RefreshSequence {
		get {
			return self.refreshSequenceStorage as! RefreshSequence
		}
	}
	
	private let refreshSequenceStorage: Any!
	
	var colorScheme: ColorScheme?
	
	private init() {
		if #available(iOS 16, macOS 13, *) {
			self.refreshSequenceStorage = RefreshSequence(interval: .seconds(5))
		} else {
			self.refreshSequenceStorage = nil
		}
	}
	
}
