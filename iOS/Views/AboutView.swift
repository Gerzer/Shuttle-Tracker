//
//  AboutView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 3/4/22.
//

import SwiftUI

struct AboutView: View {
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	var body: some View {
		Form {
			Section {
				NavigationLink("App Information") {
					InfoView()
				}
				NavigationLink("Privacy Information") {
					PrivacyView()
				}
				Button("See What’s New") {
					self.sheetStack.push(.whatsNew)
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

struct AboutViewPreviews: PreviewProvider {
	
	static var previews: some View {
		AboutView()
	}
	
}
