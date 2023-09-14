//
//  PrivacyView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

struct PrivacyView: View {
	
	@State
	private var doShowMailFailedAlert = false
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	var body: some View {
		ScrollView {
			#if os(macOS)
			Text("Privacy")
				.font(.largeTitle)
				.bold()
				.padding(.vertical)
			#endif // os(macOS)
			VStack(alignment: .leading) {
				#if os(iOS)
				Section {
					Text("Shuttle Tracker sends your location data to our server only when Board Bus is activated and stops sending these data when Board Bus is deactivated. You can activate Board Bus manually by tapping “Board Bus” or automatically by positioning your device within Bluetooth range of a Shuttle Tracker Node device on a bus if you opted in to the Shuttle Tracker Network. You can deactivate Board Bus manually by tapping “Leave Bus” or automatically by positioning your device out of Bluetooth range of a Shuttle Tracker Node device on a bus if you opted in to the Shuttle Tracker Network. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, RIN, or any other information that might identify you or your device. We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates. Even if you opt in to the Shuttle Tracker Network, we never track your location unless you manually activate Board Bus or physically board a bus. Your device might alert you to Shuttle Tracker’s location monitoring in the background even when Shuttle Tracker isn’t actually tracking your location. This is due to a system limitation; Shuttle Tracker occasionally scans for Shuttle Tracker Node devices in the  background, and your device might show that activity as location tracking. The results of these scans never leave your device, and we only start collecting location data if a scan indicates that you’re physically on a bus.")
						.padding(.bottom)
				} header: {
					Text("Location")
						.font(.headline)
				}
				#endif
				Section {
					Text("Shuttle Tracker automatically detects errors and uploads diagnostic logs to our server when they occur. These logs aren’t associated with your name, Apple ID, RCS ID, RIN, or any other information that might identify you or your device. They contain information about, for example, failed network requests. We redact sensitive information like your location, replacing those data with irreversible hashes. These hashes let us correlate different logs without revealing any of the redacted information. Logs are retained indefinitely; contact us if you want to request that we delete a log from our server. Due to the privacy-preserving nature of how we identify logs, we might not be able to find and to verify the log that you want to delete. You can see a record of recently uploaded logs or disable automatic uploads entirely in Settings > Logging & Analytics.")
						.padding(.bottom)
				} header: {
					Text("Logging")
						.font(.headline)
				}
				Section {
					Text("If you opt in to analytics, then Shuttle Tracker will send anonymous usage data to our server. These data include your app settings, feature usage frequency, and other similar metrics. No analytics data are ever collected unless you explicitly opt in. You can see a record of recently uploaded analytics reports or opt-in status in Settings > Logging & Analytics.")
						.padding(.bottom)
				} header: {
					Text("Analytics")
						.font(.headline)
				}
				#if os(iOS)
				Section {
					Button("Contact Our Privacy Team") {
						if MailComposeView.canSendMail {
							self.sheetStack.push(
								.mailCompose(
									subject: "Privacy Inquiry",
									toRecipients: ["privacy@shuttletracker.app"]
								)
							)
						} else {
							Task {
								await self.sendMail()
							}
						}
					}
						.padding(.bottom)
				}
				#endif // os(iOS)
			}
				.padding(.horizontal)
		}
			.navigationTitle("Privacy")
			.alert("Mail Failed", isPresented: self.$doShowMailFailedAlert) {
				Button("Retry") {
					Task {
						await self.sendMail()
					}
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("The mail compose interface couldn’t be shown.")
			}
			.toolbar {
				#if os(iOS)
				ToolbarItem {
					CloseButton()
				}
				#elseif os(macOS) // os(iOS)
				ToolbarItem {
					Button("Contact Our Privacy Team") {
						Task {
							await self.sendMail()
						}
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Close") {
						self.sheetStack.pop()
					}
				}
				#endif // os(macOS)
		}
			.sheetPresentation(
				provider: ShuttleTrackerSheetPresentationProvider(sheetStack: self.sheetStack),
				sheetStack: self.sheetStack
			)
	}
	
	private func sendMail() async {
		let url = URL(string: "mailto:privacy@shuttletracker.app")!
		#if canImport(UIKit)
		guard UIApplication.shared.canOpenURL(url) else {
			self.doShowMailFailedAlert = true
			Logging.withLogger(for: .mailCompose, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Can’t open URL to send privacy mail")
			}
			return
		}
		let success = await UIApplication.shared.open(url)
		#elseif canImport(AppKit) // canImport(UIKit)
		let success = NSWorkspace.shared.open(url)
		#endif // canImport(AppKit)
		if !success {
			self.doShowMailFailedAlert = true
			Logging.withLogger(for: .mailCompose, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to open URL to send privacy mail")
			}
			return
		}
	}
	
}

struct PrivacyViewPreviews: PreviewProvider {
	
	static var previews: some View {
		PrivacyView()
			.environmentObject(ShuttleTrackerSheetStack())
	}
	
}
