//
//  WhatsNewSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 3/19/23.
//

import SwiftUI

struct WhatsNewSheet: View {
	
	let onboarding: Bool
	
	var body: some View {
		NavigationView {
			if #available(iOS 16, *) {
				WhatsNewView(onboarding: self.onboarding)
					.toolbar(.hidden, for: .navigationBar)
			} else {
				WhatsNewView(onboarding: self.onboarding)
					.navigationBarHidden(true)
			}
		}
	}
	
}

struct WhatsNewSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		WhatsNewSheet(onboarding: false)
			.environmentObject(ViewState.shared)
			.environmentObject(SheetStack())
	}
	
}
