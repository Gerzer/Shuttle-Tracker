//
//  LegendToast.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 8/31/21.
//

import SwiftUI

struct LegendToast: View {
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	enum HeadlineText: String {
		
		case tip = "Here’s a tip!"
		case reminder = "Just in case you forgot…"
		
	}
	
	private var highQualityString: String {
		get {
			return self.appStorageManager.colorBlindMode ? "The scope icon indicates high-quality location data." : "Green buses indicate high-quality location data."
		}
	}
	
	private var lowQualityString: String {
		get {
			return self.appStorageManager.colorBlindMode ? "The dotted-circle icon indicates low-quality location data." : "Red buses indicate low-quality location data."
		}
	}
	
	private var highQualityAttributedString: AttributedString {
		get {
			var attributedString = AttributedString(self.highQualityString)
			if self.appStorageManager.colorBlindMode {
				let scopeRange = attributedString.range(of: "scope")!
				attributedString[scopeRange].inlinePresentationIntent = .stronglyEmphasized
			} else {
				let greenRange = attributedString.range(of: "Green")!
				attributedString[greenRange].foregroundColor = .green
				attributedString[greenRange].inlinePresentationIntent = .stronglyEmphasized
			}
			let highQualityRange = attributedString.range(of: "high-quality")!
			attributedString[highQualityRange].inlinePresentationIntent = .stronglyEmphasized
			return attributedString
		}
	}
	
	private var lowQualityAttributedString: AttributedString {
		get {
			var attributedString = AttributedString(self.lowQualityString)
			if self.appStorageManager.colorBlindMode {
				let dottedCircleRange = attributedString.range(of: "dotted-circle")!
				attributedString[dottedCircleRange].inlinePresentationIntent = .stronglyEmphasized
			} else {
				let redRange = attributedString.range(of: "Red")!
				attributedString[redRange].foregroundColor = .red
				attributedString[redRange].inlinePresentationIntent = .stronglyEmphasized
			}
			let lowQualityRange = attributedString.range(of: "low-quality")!
			attributedString[lowQualityRange].inlinePresentationIntent = .stronglyEmphasized
			return attributedString
		}
	}
	
	var body: some View {
		Toast(self.viewState.legendToastHeadlineText?.rawValue ?? "Legend", item: self.$viewState.toastType) { (_, _) in
			HStack {
				ZStack {
					Circle()
						.fill(.green)
					Image(systemName: self.appStorageManager.colorBlindMode ? "scope" : "bus")
						.resizable()
						.frame(width: 30, height: 30)
						.foregroundColor(.white)
				}
					.frame(width: 50)
				Text(self.highQualityAttributedString)
					.accessibilityShowsLargeContentViewer()
			}
				.frame(height: 50)
			Spacer()
				.frame(height: 15)
			HStack {
				ZStack {
					Circle()
						.fill(self.appStorageManager.colorBlindMode ? .purple : .red)
					Image(systemName: self.appStorageManager.colorBlindMode ? "circle.dotted" : "bus")
						.resizable()
						.frame(width: 30, height: 30)
						.foregroundColor(.white)
				}
					.frame(width: 50)
				Text(self.lowQualityAttributedString)
					.accessibilityShowsLargeContentViewer()
			}
				.frame(height: 50)
		}

	}
	
}

struct OnboardingToastPreviews: PreviewProvider {
	
	static var previews: some View {
		LegendToast()
			.environmentObject(ViewState.shared)
	}
	
}
