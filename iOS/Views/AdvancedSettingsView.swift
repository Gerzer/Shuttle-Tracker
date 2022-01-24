//
//  AdvancedSettingsView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 1/23/22.
//

import SwiftUI

struct AdvancedSettingsView: View {
	
	@AppStorage("BaseURL") private var baseURL = URL(string: "https://shuttletracker.app")!
	
	@AppStorage("MaximumStopDistance") private var maximumStopDistance = 20
	
	var body: some View {
		Form {
			Section {
				HStack {
					Text("\(self.maximumStopDistance) meters")
					Spacer()
					Stepper("Maximum Stop Distance", value: self.$maximumStopDistance, in: 1 ... 100)
						.labelsHidden()
				}
			} header: {
				Text("Maximum Stop Distance")
			} footer: {
				Text("The maximum distance in meters from the nearest stop at which you can board a bus.")
			}
			if #available(iOS 15, *) {
				Section {
					TextField("Server Base URL", value: self.$baseURL, format: .url)
						.labelsHidden()
						.keyboardType(.URL)
				} header: {
					Text("Server Base URL")
				} footer: {
					Text("The base URL for the API server. Changing this setting could make the rest of the app stop working properly.")
				}
			}
			Section {
				if #available(iOS 15.0, *) {
					Button("Reset", role: .destructive) {
						self.baseURL = URL(string: "https://shuttletracker.app")!
						self.maximumStopDistance = 20
					}
				} else {
					Button("Reset") {
						self.baseURL = URL(string: "https://shuttletracker.app")!
						self.maximumStopDistance = 20
					}
				}
			}
		}
			.navigationTitle("Advanced")
	}
	
}

struct AdvancedSettingsViewPreviews: PreviewProvider {
	
	static var previews: some View {
		AdvancedSettingsView()
	}
	
}
