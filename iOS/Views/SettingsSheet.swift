//
//  SettingsSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SettingsSheet: View {
	
	@EnvironmentObject private var navigationState: NavigationState
	
	var body: some View {
		NavigationView {
			SettingsView()
				.navigationTitle("Settings")
				.toolbar {
					Button {
						self.navigationState.sheetType = nil
					} label: {
						if #available(iOS 15.0, macOS 12.0, *) {
							Image(systemName: "xmark.circle.fill")
								.symbolRenderingMode(.hierarchical)
								.resizable()
								.opacity(0.5)
								.frame(width: ViewUtilities.Constants.sheetCloseButtonDimension, height: ViewUtilities.Constants.sheetCloseButtonDimension)
						} else {
							Text("Close")
								.fontWeight(.semibold)
						}
					}
						.buttonStyle(.plain)
				}
		}
	}
	
}

struct SettingsSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		SettingsSheet()
	}
	
}
