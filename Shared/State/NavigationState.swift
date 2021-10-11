//
//  NavigationState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import Foundation
import Combine

class NavigationState: ObservableObject {
	
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
	
	static let sharedInstance = NavigationState()
	
	@Published var sheetType: SheetType?
	
	@Published var alertType: AlertType?
	
	@Published var toastType: ToastType?
	
	private init() { }
	
}
