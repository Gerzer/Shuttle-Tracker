//
//  SettingsView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SettingsView: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	@AppStorage("colorBlindMode") private var colorBlindMode = false
	
	var body: some View {
		Form {
			#if os(iOS)
			Section {
				Toggle("Color-Blind Mode", isOn: self.$colorBlindMode)
			} footer: {
				Text("Modifies bus markers so that they're distinguishable by icon in addition to color.")
			}
			#elseif os(macOS) // os(iOS)
			Toggle("Distinguish bus markers by icon", isOn: self.$colorBlindMode)
			#endif // os(macOS)
		}
			.onChange(of: self.colorBlindMode) { (_) in
				withAnimation {
					self.viewState.toastType = .legend
					self.viewState.onboardingToastHeadlineText = nil
				}
			}
	}
	
}

struct SettingsViewPreviews: PreviewProvider {
	
	static var previews: some View {
		SettingsView()
	}
	
}
