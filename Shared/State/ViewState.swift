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
	
	enum SheetType: IdentifiableByHashValue {
		
		case privacy
		
		case settings
		
		case info
		
	}

	enum AlertType: IdentifiableByHashValue {
		
		case noNearbyBus
		
	}

	enum ToastType: IdentifiableByHashValue {
		
		case legend
		
	}
	
	static let sharedInstance = ViewState()
	
	@Published var sheetType: SheetType?
	
	@Published var alertType: AlertType?
	
	@Published var toastType: ToastType?
	
	@Published var onboardingToastHeadlineText: LegendToast.HeadlineText?
	
	private init() { }
	
}
