//
//  DebugModeToast.swift
//  Shuttle Tracker (iOS)
//
//  Created by Truong Tommy on 3/4/22.
//

import SwiftUI

@available(iOS 16, *)
struct DebugModeToast: View {
	
	private static let dismissalTimeInterval: TimeInterval = 1
	
	@EnvironmentObject
	private var viewState: ViewState
	
	var body: some View {
		Toast("Location submission", item: self.$viewState.toastType) { (item, dismiss) in
			VStack(alignment: .leading) {
				switch item {
				case .debugMode(let statusCode):
					if statusCode is Error {
						Text("The location submission failed.")
					} else {
						Text("The location submission succeeded.")
					}
					Text("HTTP \(statusCode.rawValue) \(statusCode.message)")
						.monospaced()
				default:
					Text("The submission status is unknown.")
				}
			}
		}
	}
	
}

@available(iOS 16, *)
struct DebugModeToastPreviews: PreviewProvider {
	
	static var previews: some View {
		DebugModeToast()
			.environmentObject(ViewState.shared)
	}
	
}
