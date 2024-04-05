//
//  AboutView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 3/4/22.
//

import SwiftUI

struct AboutView: View {
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	var body: some View {
		Form {
			Section {
				NavigationLink("App Information") {
					InfoView()
				}
				NavigationLink("Privacy Information") {
					PrivacyView()
				}
				Button("Show What’s New") {
					self.sheetStack.push(.whatsNew(onboarding: false))
				}
			}
		}
			.navigationTitle("About")
			.toolbar {
				ToolbarItem {
					CloseButton()
				}
			}
	}
	
}

#Preview {
	AboutView()
		.environmentObject(ShuttleTrackerSheetStack())
}
