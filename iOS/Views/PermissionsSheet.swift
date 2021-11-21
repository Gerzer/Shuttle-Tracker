//
//  PermissionsSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

struct PermissionsSheet: View {
	
	var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				Text("Shuttle Tracker requires access to your location to provide shuttle-tracking features and to improve data accuracy for everyone.")
					.padding(.bottom)
				Button("View Privacy Information") {
					SheetStack.push(.privacy)
				}
				Spacer()
				Button {
					LocationUtilities.locationManager.requestWhenInUseAuthorization()
					SheetStack.pop()
				} label: {
					Text("Continue")
						.bold()
				}
					.buttonStyle(BlockButtonStyle())
				
			}
				.padding()
				.navigationTitle("Permissions")
				.sheet(item: SheetStack.sheetType) { (sheetType) in
					switch sheetType {
					case .privacy:
						PrivacySheet()
					default:
						EmptyView()
					}
				}
		}
	}
	
}

struct PermissionsSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		PermissionsSheet()
	}
	
}
