//
//  PermissionsSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

struct PermissionsSheet: View {
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	@Environment(\.openURL) private var openURL
	
	var body: some View {
		SheetPresentationWrapper {
			NavigationView {
				VStack(alignment: .leading) {
					Text("Shuttle Tracker requires access to your location to provide shuttle-tracking features and to improve data accuracy for everyone.")
						.padding(.bottom)
					Button("View Privacy Information") {
						self.sheetStack.push(.privacy)
					}
						.padding(.bottom)
					if #available(iOS 15, *) {
						Group {
							switch LocationUtilities.locationManager.authorizationStatus {
							case .authorizedWhenInUse, .authorizedAlways:
								HStack {
									Image(systemName: "gear.badge.checkmark")
										.resizable()
										.scaledToFit()
										.frame(width: 50, height: 50)
									Text("You’ve already granted location permission. Thanks!")
								}
							case .restricted, .denied:
								HStack {
									Image(systemName: "gear.badge.checkmark")
										.resizable()
										.frame(width: 50, height: 50)
									Text("Shuttle Tracker doesn’t have location permission; you can change this in Settings.")
								}
							case .notDetermined:
								HStack {
									Image(systemName: "gear.badge.checkmark")
										.resizable()
										.frame(width: 50, height: 50)
									Text("Tap “Continue” and then grant location permission.")
								}
							@unknown default:
								fatalError()
							}
						}
							.symbolRenderingMode(.multicolor)
					}
					Spacer()
					Button {
						switch LocationUtilities.locationManager.authorizationStatus {
						case .notDetermined:
							LocationUtilities.locationManager.requestWhenInUseAuthorization()
						case .restricted, .denied:
							let url = try! UIApplication.openSettingsURLString.asURL()
							self.openURL(url)
						case .authorizedWhenInUse, .authorizedAlways:
							break
						@unknown default:
							fatalError()
						}
						self.sheetStack.pop()
					} label: {
						Text("Continue")
							.bold()
					}
						.buttonStyle(BlockButtonStyle())
					
				}
					.padding()
					.navigationTitle("Permissions")
					.toolbar {
						ToolbarItem {
							CloseButton()
						}
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
