//
//  SettingsSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SettingsSheet: View {
	
	var body: some View {
		NavigationView {
			SettingsView()
				.navigationTitle("Settings")
				.toolbar {
					ToolbarItem {
						CloseButton()
					}
				}
		}
	}
	
}

#Preview {
	SettingsSheet()
}
