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
	private var sheetStack: SheetStack
	
	var body: some View {
		SheetPresentationWrapper {
			VStack(alignment: .leading) {
				HStack {
					Spacer()
                    VStack {
                        Image(systemName: "chart.bar.xaxis")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .frame(width: 60,height: 60)
                            .foregroundColor(.blue)
                        Text("Analytics")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                    }
					Spacer()
				}
                .padding(.bottom)
//				Text("Share analytics with the Shuttle Tracker team to help us improve the app. You can see a record of uploaded analytics entries or enable or disable the feature in Settings > Logging & Analytics.")
                Text("Share your logs.")
                    .bold()
                    .font(.headline)
                Text("Help us improve Shuttle Tracker. You can also see your record of uploaded analytics entries.")
					.accessibilityShowsLargeContentViewer()
					.padding(.bottom)
                
                HStack {
                    Spacer()
                    AnalyticsSampleView()
                        .frame(width: 350,height: 250)
                        .cornerRadius(18)
                        .shadow(radius: 10)
                    Spacer()
                }
                
                Spacer()

				Button("Show Privacy Information") {
					self.sheetStack.push(.privacy)
				}
                .padding(.bottom)
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
		}
	}
	
}

struct AnalyticsOnboardingViewPreviews: PreviewProvider {
	
	static var previews: some View {
		AnalyticsOnboardingView()
			.environmentObject(AppStorageManager.shared)
			.environmentObject(SheetStack())
	}
	
}

struct AnalyticsSampleView : View {
    var body: some View {
        Image("AnalyticsScreenshot")
            .resizable()
            .scaledToFit()
    }
}
