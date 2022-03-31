//
//  SettingsSheet.swift
//  Shuttle Tracker
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

struct SettingsSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		SettingsSheet()
	}
	
}
