//
//  LoggingAnalyticsSettingsView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/18/22.
//

import SwiftUI

struct LoggingAnalyticsSettingsView: View {
	
	@State
	private var doShowConfirmationDialog = false
	
	@State
	private var didUploadLog = false
	
	@State
	private var didClearUploadedLogs = false
	
	@State
	private var logUploadError: WrappedError?
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	var body: some View {
		Form {
			Section {
				Toggle("Automatically Upload Logs", isOn: self.appStorageManager.$doUploadLogs)
				Button("Upload Log Now" + (self.didUploadLog ? " ✓" : ""), action: self.uploadLog)
					.disabled(self.didUploadLog)
			}
			Section {
				List(self.appStorageManager.uploadedLogs) { (log) in
					NavigationLink {
						// TODO: Extract subview and improve layout/styling
						ScrollView {
							HStack {
								Text("ID: \(log.id.uuidString)")
									.onTapGesture {
										// TODO: Copy to system clipboard
									}
								Spacer()
							}
							Text(log.content)
						}
					} label: {
						VStack {
							// TODO: Customize date format
							Text(DateFormatter().string(from: log.date))
								.bold()
							
							Text(log.id.uuidString)
						}
					}
				}
				Button(
					"Clear Uploaded Logs" + (self.didClearUploadedLogs ? " ✓" : ""),
					role: .destructive
				) {
					self.doShowConfirmationDialog = true
				}
					.disabled(self.didClearUploadedLogs || self.appStorageManager.uploadedLogs.isEmpty) // TODO: Reenable when a new log is added
			} header: {
				Text("Uploaded Logs")
			}
		}
			.navigationTitle("Logging & Analytics")
			.toolbar {
				ToolbarItem {
					CloseButton()
				}
			}
			.alert(isPresented: self.$logUploadError.isNotNil, error: self.logUploadError) {
				Button("Retry", action: self.uploadLog)
				Button("Cancel", role: .cancel) {
					self.didUploadLog = false
				}
			}
			.confirmationDialog("Clear Uploaded Logs", isPresented: self.$doShowConfirmationDialog) {
				Button("Delete Uploaded Logs", role: .destructive) {
					self.appStorageManager.uploadedLogs.removeAll()
					self.didClearUploadedLogs = true
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure that you want to clear the record of logs that have been uploaded from this device? This will only clear the logs locally; since uploaded logs are not tied to your device or your identity to protect your privacy, they can’t be deleted from the server.")
			}
	}
	
	private func uploadLog() {
		self.didUploadLog = true
		Task {
			do {
				try await Logging.uploadLog()
			} catch let error {
				self.logUploadError = WrappedError(error)
				Logging.withLogger { (logger) in
					logger.log(level: .error, "Couldn’t upload logs: \(error)")
				}
			}
		}
	}
	
}
