//
//  NavigationState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import Foundation
import Combine

class NavigationState: ObservableObject {
	
	static let sharedInstance = NavigationState()
	
	@Published var sheetType: SheetType?
	
	@Published var alertType: AlertType?
	
	private init() { }
	
}

enum SheetType: IdentifiableByHashValue {
	
	case privacy
	
	case settings
	
}

enum AlertType: IdentifiableByHashValue {
	
	case noNearbyBus
	
}
