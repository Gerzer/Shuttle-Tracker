//
//  ViewState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import Combine
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
	
	enum ToastType: Identifiable {
		
		case legend, boardBus
		
		var id: Self {
			get {
				return self
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
	
	@Published
	var legendToastHeadlineText: LegendToast.HeadlineText?
	
	let handles = Handles()
	
	private init() { }
	
}
