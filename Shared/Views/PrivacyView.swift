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
	private var sheetStack: SheetStack
	
	var body: some View {
		SheetPresentationWrapper {
			ScrollView {
				#if os(macOS)
				Text("Privacy")
					.font(.largeTitle)
					.bold()
					.padding(.vertical)
				#endif // os(macOS)
                
                VStack(alignment: .leading, spacing: 0) {
					#if os(iOS)
					Section {
                        VStack(spacing: 0){
                            Text("Your location data are associated with an _**anonymous**_, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, RIN, or any other information that might identify you or your device.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                            #if os(macOS)
                                .background(Color(.controlBackgroundColor))
                            #else
                                .background(Color(.systemGray5))
                            #endif
                                .padding(.bottom, 10)
                            Text("Shuttle Tracker sends your location data to our server _only_ when you tap **\"Board Bus\"** and stops sending these data when you tap **\"Leave Bus\"**.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                            #if os(macOS)
                                .background(Color(.controlBackgroundColor))
                            #else
                                .background(Color(.systemGray5))
                            #endif
                                .padding(.bottom, 10)
                            Text("We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                            #if os(macOS)
                                .background(Color(.controlBackgroundColor))
                            #else
                                .background(Color(.systemGray5))
                            #endif
                        }
                            .cornerRadius(20)
                            .padding(.bottom)
					} header: {
						Text("Location")
                            .padding(.vertical, 5)
                            .padding(.top)
                            .font(.title)
					}
					#endif
					Section {
                        VStack(spacing: 0){
                            Text("Shuttle Tracker automatically detects errors and uploads diagnostic logs to our server when they occur. These logs aren’t associated with your name, Apple ID, RCS ID, RIN, or any other information that might identify you or your device.They contain information about, for example, failed network requests.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                            #if os(macOS)
                                .background(Color(.controlBackgroundColor))
                            #else
                                .background(Color(.systemGray5))
                            #endif
                                .padding(.bottom, 10)
                            Text("We redact sensitive information like your location, replacing those data with irreversible hashes. These hashes let us correlate different logs without revealing any of the redacted information. Logs are retained indefinitely; contact us if you want to request that we delete a log from our server.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                            #if os(macOS)
                                .background(Color(.controlBackgroundColor))
                            #else
                                .background(Color(.systemGray5))
                            #endif
                                .padding(.bottom, 10)
                            VStack(spacing: 0){
                                Text("Due to the privacy-preserving nature of how we identify logs, we might not be able to find and to verify the log that you want to delete. You can see a record of recently uploaded logs or disable automatic uploads entirely in ")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 3)
                                HStack(spacing: 0){
                                    NavigationLink {
                                        LoggingAnalyticsSettingsView()
                                    } label: {
                                        Text("Logging & Analytics")
                                            .foregroundColor(Color.blue)
                                            .bold()
                                    }
                                    Text(".")
                                    Spacer()
                                }
                            }
                                .padding(10)
                            #if os(macOS)
                                .background(Color(.controlBackgroundColor))
                            #else
                                .background(Color(.systemGray5))
                            #endif
                        }
                            .cornerRadius(20)
							.padding(.bottom)
					} header: {
						Text("Logging")
                            .padding(.vertical, 5)
                            .font(.title)
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
                    .background(.ultraThickMaterial)
                    .cornerRadius(20)
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
		}
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
			.environmentObject(SheetStack())
	}
	
}
