//
//  AnalyticsOnboardingView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/19/23.
//

import SwiftUI

struct AnalyticsOnboardingView: View {
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Spacer()
				Text("Analytics")
					.font(.largeTitle)
					.bold()
					.multilineTextAlignment(.center)
				Spacer()
			}
				.padding(.vertical)
			Text("Share analytics with the Shuttle Tracker team to help us improve the app. You can see a record of uploaded analytics entries or enable or disable the feature in Settings > Logging & Analytics.")
				.accessibilityShowsLargeContentViewer()
				.padding(.bottom)
			Button("Show Privacy Information") {
				self.sheetStack.push(.privacy)
			}
			Spacer()
			HStack {
				Button {
					self.appStorageManager.doShareAnalytics = false
					self.sheetStack.pop()
				} label: {
					Text("Don’t Share")
						#if os(iOS)
						.bold()
						#endif // os(iOS)
						.padding(5)
						.frame(maxWidth: .infinity)
				}
					.buttonStyle(.bordered)
				Button {
					self.appStorageManager.doShareAnalytics = true
					self.sheetStack.pop()
				} label: {
					Text("Share Analytics")
						#if os(iOS)
						.bold()
						#endif // os(iOS)
						.padding(5)
						.frame(maxWidth: .infinity)
				}
					.buttonStyle(.borderedProminent)
			}
		}
			.padding(.horizontal)
			.padding(.bottom)
			.sheetPresentation(
				provider: ShuttleTrackerSheetPresentationProvider(sheetStack: self.sheetStack),
				sheetStack: self.sheetStack
			)
	}
	
}

#Preview {
	AnalyticsOnboardingView()
		.environmentObject(AppStorageManager.shared)
		.environmentObject(ShuttleTrackerSheetStack())
}
