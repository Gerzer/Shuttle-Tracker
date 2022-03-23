//
//  PrivacyView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

struct PrivacyView: View {
	
	var body: some View {
		VStack {
			Text("Shuttle Tracker sends your location data to our server only when you tap “Board Bus” and stops sending these data when you tap “Leave Bus”. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, or any other identifying information. We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates.")
			Spacer()
		}
			.padding()
			.navigationTitle("Privacy")
			.toolbar {
				#if !os(macOS)
				ToolbarItem {
					CloseButton()
				}
				#endif // !os(macOS)
			}
	}
	
}

struct PrivacyViewPreviews: PreviewProvider {
	
	static var previews: some View {
		PrivacyView()
	}
	
}
