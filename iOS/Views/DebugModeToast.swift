//
//  DebugModeToast.swift
//  Shuttle Tracker (iOS)
//
//  Created by Truong Tommy on 3/4/22.
//

import SwiftUI

@available(iOS 16, *)
struct DebugModeToast: View {
	
	@State
	private var dismissalTask: Task<Void, any Error>?
	
	@EnvironmentObject
	private var viewState: ViewState
	
	var body: some View {
        
		Toast("A location was submitted…", item: self.$viewState.toastType) { (item, dismiss) in
			VStack(alignment: .leading) {
				switch item {
				case .debugMode(let statusCode):
					if statusCode is any Error {
						Text("The location submission failed.")
							.foregroundColor(.red)
							.accessibilityShowsLargeContentViewer()
					} else {
						Text("The location submission succeeded.")
							.foregroundColor(.green)
							.accessibilityShowsLargeContentViewer()
					}
					Text("HTTP \(statusCode.rawValue) \(statusCode.message)")
						.monospaced()
						.accessibilityShowsLargeContentViewer()
                
				default:
					Text("The submission status is unknown.")
						.accessibilityShowsLargeContentViewer()
                
				}
				ProgressView(timerInterval: .now ... .now.addingTimeInterval(DebugMode.toastTimeInterval)) {
					EmptyView()
				} currentValueLabel: {
					EmptyView()
				}
			}
				.onAppear {
					self.dismissalTask = Task {
						try await Task.sleep(for: .seconds(DebugMode.toastTimeInterval - 0.3)) // Don’t catch the error because cancellation is expected
						dismiss()
					}
				}
				.onDisappear {
					self.dismissalTask?.cancel()
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
