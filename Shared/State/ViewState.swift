//
//  ViewState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import Foundation
import Combine
import OnboardingKit

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
		
		case legend, boardBus, Network_Location_request
		
		var id: Self {
			get {
				return self
			}
		}
		
	}
	
	enum StatusText: String {
		
		case mapRefresh = "The map automatically refreshes every 5 seconds."
		
		case locationData = "You’re helping out other users with real-time bus location data."
		
		case thanks = "Thanks for helping other users with real-time bus location data!"
		
	}
	
	static let shared = ViewState()
	
	@Published var alertType: AlertType?
	
	@Published var toastType: ToastType?
	
	@Published var statusText = StatusText.mapRefresh
	
	@Published var legendToastHeadlineText: LegendToast.HeadlineText?
	
	let handles = Handles()
	
	private init() { }
	
}
