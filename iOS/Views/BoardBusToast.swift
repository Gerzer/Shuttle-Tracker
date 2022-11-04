//
//  BoardBusToast.swift
//  Shuttle Tracker (iOS)
//
//  Created by Andrew Emanuel on 11/16/21.
//

import SwiftUI

struct BoardBusToast: View {
	
	@EnvironmentObject
	private var viewState: ViewState
	
	var body: some View {
		Toast("You can help!") {
			withAnimation {
				self.viewState.toastType = nil
			}
		} content: {
			Text("Tap “Board Bus” whenever you board a bus to help make Shuttle Tracker more accurate for everyone.")
		}
	}
	
}

struct ReminderToastPreviews: PreviewProvider {
	
	static var previews: some View {
		BoardBusToast()
			.environmentObject(ViewState.shared)
	}
	
}
