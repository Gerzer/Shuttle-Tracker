//
//  PermissionsSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

struct PermissionsSheet: View {
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	private let sheetStackHandle = SheetStack.shared.register()
	
	var body: some View {
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
				.sheet(item: self.sheetStack[self.sheetStackHandle]) { (sheetType) in
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
			.environmentObject(SheetStack.shared)
	}
	
}
