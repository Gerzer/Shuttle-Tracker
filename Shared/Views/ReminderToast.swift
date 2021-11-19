//
//  ReminderToast.swift
//  Shuttle Tracker
//
//  Created by Andrew Emanuel on 11/16/21.
//

import SwiftUI

struct ReminderToast: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	@AppStorage("colorBlindMode") private var colorBlindMode = false
	
	enum HeadlineText: String {
		
		case tip = "Here’s a tip!"
		case reminder = "Just in case you forgot..."
		
	}
	
	private var highQualityString: String {
		get {
			return "Please press the Board Bus button when you ride the shuttle!"
		}
	}
	
	private var lowQualityString: String {
		get {
			return "Anonymously contributing your location helps make Shuttle Tracker better for everyone. Don't forget to tap Leave Bus when getting off!"
		}
	}
	
	@available(iOS 15, macOS 12, *) private var highQualityAttributedString: AttributedString {
		get {
			var attributedString = AttributedString(self.highQualityString)

			let boldRange = attributedString.range(of: "Board Bus")!
			attributedString[boldRange].inlinePresentationIntent = .stronglyEmphasized
			
			return attributedString
		}
	}
	
	@available(iOS 15, macOS 12, *) private var lowQualityAttributedString: AttributedString {
		get {
			var attributedString = AttributedString(self.lowQualityString)

			let boldRange = attributedString.range(of: "Leave Bus")!
			attributedString[boldRange].inlinePresentationIntent = .stronglyEmphasized
			
			return attributedString
		}
	}
	
	var body: some View {
		Toast(self.viewState.onboardingToastHeadlineText?.rawValue ?? "Reminder") {
			withAnimation {
				self.viewState.toastType = nil
			}
		} content: {
			HStack {
				if #available(iOS 15, macOS 12, *) {
					Text(self.highQualityAttributedString)
				} else {
					Text(self.highQualityString)
				}
			}
				.frame(height: 50)
			HStack {
				if #available(iOS 15, macOS 12, *) {
					Text(self.lowQualityAttributedString)
				} else {
					Text(self.lowQualityString)
				}
			}
				.frame(height: 90)
		}

	}
	
}

struct ReminderToastPreviews: PreviewProvider {
	
	static var previews: some View {
		ReminderToast()
			.environmentObject(ViewState.sharedInstance)
	}
	
}
