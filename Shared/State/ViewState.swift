//
//  ViewState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import Combine
import HTTPStatus
import OnboardingKit

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
		
		case legend
		
		case boardBus
		
		case debugMode(statusCode: any HTTPStatusCode)
		
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
	
	enum StatusText: String {
		
		case mapRefresh = "The map automatically refreshes every 5 seconds."
		
		case locationData = "You’re helping out other users with real-time bus location data."
		
		case thanks = "Thanks for helping other users with real-time bus location data!"
		
	}
	
	static let shared = ViewState()
	
	@Published
	var alertType: AlertType?
	
	@Published
	var toastType: ToastType?
	
	@Published
	var statusText = StatusText.mapRefresh
	
	@Published
	var legendToastHeadlineText: LegendToast.HeadlineText?
	
	let handles = Handles()
	
	private init() { }
	
}
