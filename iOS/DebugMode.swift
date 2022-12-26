//
//  DebugMode.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 12/25/22.
//

import HTTPStatus
import SwiftUI

actor DebugMode {
	
	static let shared = DebugMode()
	
	static let toastTimeInterval: TimeInterval = 3
	
	private var toastActivationDate: Date?
	
	func showToast(statusCode newStatusCode: any HTTPStatusCode) async {
		guard await AppStorageManager.shared.debugMode else {
			return
		}
		if case .debugMode = await ViewState.shared.toastType {
			return
		}
		if let toastActivationDate = self.toastActivationDate {
			guard abs(toastActivationDate.timeIntervalSinceNow + 1) > Self.toastTimeInterval else {
				return
			}
		}
		self.toastActivationDate = .now
		await MainActor.run {
			withAnimation {
				ViewState.shared.toastType = .debugMode(statusCode: newStatusCode)
			}
		}
	}
	
	private init() { }
	
}
