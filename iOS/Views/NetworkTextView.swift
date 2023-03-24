//
//  NetworkTextView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 3/21/23.
//

import CoreLocation
import SwiftUI

struct NetworkTextView: View {
	
	var body: some View {
		VStack(alignment: .leading) {
			// The AttributedString(markdown:) initializer detects the list-item prefixes as Markdown syntax and drops them because it doesn’t natively support numbered lists, so we must instead concatenate them as plain text outside of the initializer.
			switch (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
			case (.authorizedAlways, .fullAccuracy):
				Text("Thanks for joining the Shuttle Tracker Network!")
			case (.notDetermined, _):
				Text(try! "1.\t" + AttributedString(markdown: "Tap the red button below."))
				Text(try! "2.\t" + AttributedString(markdown: "Select ***Allow While Using App***."))
				Text(try! "3.\t" + AttributedString(markdown: "Select ***Change to Always Allow***."))
			default:
				Text("Your location is never collected unless you’re physically riding a bus.")
				Text(try! "1.\t" + AttributedString(markdown: "Tap the red button below."))
				Text(try! "2.\t" + AttributedString(markdown: "Select ***Always*** location access."))
				Text(try! "3.\t" + AttributedString(markdown: "Enable ***Precise Location***."))
			}
		}
	}
	
}

struct NetworkTextViewPreviews: PreviewProvider {
	
	static var previews: some View {
		NetworkTextView()
	}
	
}
