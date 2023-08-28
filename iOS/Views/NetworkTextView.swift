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
			Group {
				// The AttributedString(markdown:) initializer detects the list-item prefixes as Markdown syntax and drops them because it doesn’t natively support numbered lists, so we must instead concatenate them as plain text outside of the initializer.
				switch (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
				case (.authorizedAlways, .fullAccuracy):
					EmptyView()
				case (.notDetermined, _):
					Group {
						Text(try! "1.\t" + AttributedString(markdown: "Tap the red button below."))
						Text(try! "2.\t" + AttributedString(markdown: "Select ***Allow While Using App***."))
						Text(try! "3.\t" + AttributedString(markdown: "Select ***Change to Always Allow***."))
					}
						.padding(.bottom)
				default:
					Group {
						Text(try! "1.\t" + AttributedString(markdown: "Tap the red button below."))
						Text(try! "2.\t" + AttributedString(markdown: "Select ***Always*** location access."))
						Text(try! "3.\t" + AttributedString(markdown: "Enable ***Precise Location***."))
					}
						.padding(.bottom)
				}
			}
				.font(.system(size: 20))
			DisclosureGroup("Privacy & Battery Information") {
				HStack {
					Text(try! AttributedString(markdown: "Your location is **never shared** unless you’re physically on a bus. Location services are activated only when an ultra-low-power signal from Shuttle Tracker Node is detected, so daily background **battery usage is minimal**."))
					Spacer()
				}
			}
		}
	}
	
}

struct NetworkTextViewPreviews: PreviewProvider {
	
	static var previews: some View {
		NetworkTextView()
	}
	
}
