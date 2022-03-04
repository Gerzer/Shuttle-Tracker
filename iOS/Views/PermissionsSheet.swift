//
//  PermissionsSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

struct PermissionsSheet: View {
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	var body: some View {
		SheetPresentationWrapper {
			NavigationView {
				VStack(alignment: .leading) {
					Text("Shuttle Tracker requires access to your location to provide shuttle-tracking features and to improve data accuracy for everyone.")
						.padding(.bottom)
					Button("View Privacy Information") {
						self.sheetStack.push(.privacy)
					}
					Spacer()
					Button {
						LocationUtilities.locationManager.requestWhenInUseAuthorization()
						self.sheetStack.pop()
					} label: {
						Text("Continue")
							.bold()
					}
						.buttonStyle(BlockButtonStyle())
					
				}
					.padding()
					.navigationTitle("Permissions")
			}
		}
	}
	
}

struct PermissionsSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		PermissionsSheet()
			.environmentObject(SheetStack.shared)
	}
	
}
