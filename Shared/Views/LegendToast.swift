//
//  LegendToast.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 8/31/21.
//

import SwiftUI

struct LegendToast: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	@AppStorage("colorBlindMode") private var colorBlindMode = false
	
	enum HeadlineText: String {
		
		case tip = "Here's a tip!"
		case reminder = "Just in case you forgot..."
		
	}
	
	private var highQualityString: String {
		get {
			return self.colorBlindMode ? "The scope icon indicates high-quality location data." : "Green buses have high-quality location data."
		}
	}
	
	private var lowQualityString: String {
		get {
			return self.colorBlindMode ? "The dotted-circle icon indicates low-quality location data." : "Red buses have low-quality location data."
		}
	}
	
	@available(iOS 15, macOS 12, *) private var highQualityAttributedString: AttributedString {
		get {
			var attributedString = AttributedString(self.highQualityString)
			if self.colorBlindMode {
				let scopeRange = attributedString.range(of: "scope")!
				attributedString[scopeRange].inlinePresentationIntent = .stronglyEmphasized
			} else {
				let greenRange = attributedString.range(of: "Green")!
				attributedString[greenRange].foregroundColor = .green
			}
			let highQualityRange = attributedString.range(of: "high-quality")!
			attributedString[highQualityRange].inlinePresentationIntent = .stronglyEmphasized
			return attributedString
		}
	}
	
	@available(iOS 15, macOS 12, *) private var lowQualityAttributedString: AttributedString {
		get {
			var attributedString = AttributedString(self.lowQualityString)
			if self.colorBlindMode {
				let dottedCircleRange = attributedString.range(of: "dotted-circle")!
				attributedString[dottedCircleRange].inlinePresentationIntent = .stronglyEmphasized
			} else {
				let redRange = attributedString.range(of: "Red")!
				attributedString[redRange].foregroundColor = .red
			}
			let lowQualityRange = attributedString.range(of: "low-quality")!
			attributedString[lowQualityRange].inlinePresentationIntent = .stronglyEmphasized
			return attributedString
		}
	}
	
	var body: some View {
		Toast(self.viewState.onboardingToastHeadlineText?.rawValue ?? "Legend") {
			withAnimation {
				self.viewState.toastType = nil
			}
		} content: {
			HStack {
				ZStack {
					Circle()
						.fill(.green)
					Image(systemName: self.colorBlindMode ? "scope" : "bus")
						.resizable()
						.frame(width: 30, height: 30)
						.foregroundColor(.white)
				}
					.frame(width: 50)
				if #available(iOS 15, macOS 12, *) {
					Text(self.highQualityAttributedString)
				} else {
					Text(self.highQualityString)
				}
			}
				.frame(height: 50)
			Spacer()
				.frame(height: 15)
			HStack {
				ZStack {
					Circle()
						.fill(self.colorBlindMode ? .purple : .red)
					Image(systemName: self.colorBlindMode ? "circle.dotted" : "bus")
						.resizable()
						.frame(width: 30, height: 30)
						.foregroundColor(.white)
				}
					.frame(width: 50)
				if #available(iOS 15, macOS 12, *) {
					Text(self.lowQualityAttributedString)
				} else {
					Text(self.lowQualityString)
				}
			}
				.frame(height: 50)
		}

	}
	
}

struct OnboardingToastPreviews: PreviewProvider {
	
	static var previews: some View {
		LegendToast()
	}
	
}
