//
//  LoggingAnalyticsSettingsView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/18/22.
//

import STLogging
import SwiftUI

struct LoggingAnalyticsSettingsView: View {
	
	enum LogUploadState {
		
		case waiting, uploading, uploaded
		
	}
	
	enum Category: CaseIterable {
		
		case logs, analytics
		
	}
	
	@State
	private var selectedCategory: Category = .logs
	
	@State
	private var doShowClearLogsConfirmationDialog = false
	
	@State
	private var doShowClearAnalyticsEntriesConfirmationDialog = false
	
	@State
	private var logUploadState: LogUploadState = .waiting
	
	@State
	private var didClearUploadedLogs = false
	
	@State
	private var didClearUploadedAnalyticsEntries = false
	
	@State
	private var logUploadError: WrappedError?
	
	#if os(macOS)
	@State
	private var selectedLog: Logging.Log?
	
	@State
	private var selectedAnalyticsEntry: Analytics.Entry?
	#endif // os(macOS)
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .short
		dateFormatter.doesRelativeDateFormatting = true
		return dateFormatter
	}()
	
	var body: some View {
		Form {
			Section {
				#if os(iOS)
				Toggle("Automatically Upload Logs", isOn: self.appStorageManager.$doUploadLogs)
				Button(action: self.uploadLog) {
					HStack {
						Text("Upload Log Now")
						Spacer()
						switch self.logUploadState {
						case .waiting:
							EmptyView()
						case .uploading:
							ProgressView()
						case .uploaded:
							Text("✓")
						}
					}
				}
					.disabled(.uploading ~= self.logUploadState || .uploaded ~= self.logUploadState)
				#elseif os(macOS) // os(iOS)
				HStack {
					Toggle("Automatically upload logs", isOn: self.appStorageManager.$doUploadLogs)
					Spacer()
					if case .uploading = self.logUploadState {
						ProgressView()
							.scaleEffect(0.5)
					}
					Button(action: self.uploadLog) {
						HStack {
							Text("Upload Log Now")
							switch self.logUploadState {
							case .waiting, .uploading:
								EmptyView()
							case .uploaded:
								Text("✓")
							}
						}
					}
						.disabled(.uploading ~= self.logUploadState || .uploaded ~= self.logUploadState)
				}
				#endif // os(macOS)
			}
			Section {
				#if os(iOS)
				Toggle("Share Analytics", isOn: self.appStorageManager.$doShareAnalytics)
				#elseif os(macOS) // os(iOS)
				Toggle("Share analytics", isOn: self.appStorageManager.$doShareAnalytics)
				#endif // os(macOS)
			}
			#if os(macOS)
			Divider()
			Spacer()
			#endif // os(macOS)
			Section {
				Picker("Category", selection: self.$selectedCategory) {
					ForEach(Category.allCases, id: \.self) { (category) in
						switch category {
						case .logs:
							Text("Logs")
						case .analytics:
							Text("Analytics")
						}
					}
				}
					.pickerStyle(.segmented)
					.labelsHidden()
				#if os(macOS)
				Spacer()
				#endif // os(macOS)
				switch self.selectedCategory {
				case .logs:
					#if os(iOS)
					List(
						self.appStorageManager.uploadedLogs
							.sorted { (first, second) in
								return first.date < second.date
							}
							.reversed()
					) { (log) in
						NavigationLink {
							LogDetailView(log: log)
						} label: {
							VStack(alignment: .leading) {
								Text(self.dateFormatter.string(from: log.date))
									.font(.headline)
								Text(log.id.uuidString)
									.font(.caption)
							}
						}
					}
					Button(role: .destructive) {
						self.doShowClearLogsConfirmationDialog = true
					} label: {
						HStack {
							Text("Clear Uploaded Logs")
							Spacer()
							if self.didClearUploadedLogs {
								Text("✓")
							}
						}
					}
						.disabled(self.appStorageManager.uploadedLogs.isEmpty)
					#elseif os(macOS) // os(iOS)
					HStack {
						List(
							self.appStorageManager.uploadedLogs
								.sorted { (first, second) in
									return first.date < second.date
								}
								.reversed(),
							selection: self.$selectedLog
						) { (log) in
							VStack(alignment: .leading) {
								Text(self.dateFormatter.string(from: log.date))
									.font(.headline)
								Text(log.id.uuidString)
									.font(.caption)
							}
								.tag(log)
						}
							.listStyle(.plain)
							.frame(width: 300)
							.animation(.default, value: self.appStorageManager.uploadedLogs)
						Divider()
						if let log = self.selectedLog {
							LogDetailView(log: log)
						} else {
							Spacer()
							Text("No Log Selected")
								.font(.title2)
								.multilineTextAlignment(.center)
								.foregroundColor(.secondary)
								.padding()
							Spacer()
						}
					}
					#endif // os(macOS)
				case .analytics:
					#if os(iOS)
					List(
						self.appStorageManager.uploadedAnalyticsEntries
							.sorted { (first, second) in
								return first.date < second.date
							}
							.reversed()
					) { (entry) in
						NavigationLink {
							AnalyticsDetailView(entry: entry)
						} label: {
							VStack(alignment: .leading) {
								Text(self.dateFormatter.string(from: entry.date))
									.font(.headline)
								Text(entry.id.uuidString)
									.font(.caption)
							}
						}
					}
					Button(role: .destructive) {
						self.doShowClearAnalyticsEntriesConfirmationDialog = true
					} label: {
						HStack {
							Text("Clear Uploaded Analytics Entries")
							Spacer()
							if self.didClearUploadedAnalyticsEntries {
								Text("✓")
							}
						}
					}
						.disabled(self.appStorageManager.uploadedAnalyticsEntries.isEmpty)
					#elseif os(macOS) // os(iOS)
					HStack {
						List(
							self.appStorageManager.uploadedAnalyticsEntries
								.sorted { (first, second) in
									return first.date < second.date
								}
								.reversed(),
							selection: self.$selectedAnalyticsEntry
						) { (entry) in
							VStack(alignment: .leading) {
								Text(self.dateFormatter.string(from: entry.date))
									.font(.headline)
								Text(entry.id.uuidString)
									.font(.caption)
							}
								.tag(entry)
						}
							.listStyle(.plain)
							.frame(width: 300)
							.animation(.default, value: self.appStorageManager.uploadedAnalyticsEntries)
						Divider()
						if let entry = self.selectedAnalyticsEntry {
							AnalyticsDetailView(entry: entry)
						} else {
							Spacer()
							Text("No Analytics Entry Selected")
								.font(.title2)
								.multilineTextAlignment(.center)
								.foregroundColor(.secondary)
								.padding()
							Spacer()
						}
					}
					#endif // os(macOS)
				}
			} header: {
				switch self.selectedCategory {
				case .logs:
					#if os(iOS)
					Text("Uploaded Logs")
					#elseif os(macOS) // os(iOS)
					HStack {
						Text("Uploaded Logs")
							.bold()
						Spacer()
						Button(role: .destructive) {
							self.doShowClearLogsConfirmationDialog = true
						} label: {
							HStack {
								Text("Clear")
								if self.didClearUploadedLogs {
									Text("✓")
								}
							}
						}
							.disabled(self.appStorageManager.uploadedLogs.isEmpty)
					}
					#endif // os(macOS)
				case .analytics:
					#if os(iOS)
					Text("Uploaded Analytics Entries")
					#elseif os(macOS) // os(iOS)
					HStack {
						Text("Uploaded Analytics Entries")
							.bold()
						Spacer()
						Button(role: .destructive) {
							self.doShowClearAnalyticsEntriesConfirmationDialog = true
						} label: {
							HStack {
								Text("Clear")
								if self.didClearUploadedAnalyticsEntries {
									Text("✓")
								}
							}
						}
							.disabled(self.appStorageManager.uploadedAnalyticsEntries.isEmpty)
					}
					#endif // os(macOS)
				}
			}
		}
			#if os(iOS)
			.navigationTitle("Logging & Analytics")
			.toolbar {
				CloseButton()
			}
			#endif // os(iOS)
			.alert(isPresented: self.$logUploadError.isNotNil, error: self.logUploadError) {
				Button("Retry", action: self.uploadLog)
				Button("Cancel", role: .cancel) {
					#if os(iOS)
					withAnimation {
						self.logUploadState = .waiting
					}
					#elseif os(macOS) // os(iOS)
					self.logUploadState = .waiting
					#endif // os(macOS)
				}
			}
			.confirmationDialog("Clear Uploaded Logs", isPresented: self.$doShowClearLogsConfirmationDialog) {
				Button("Clear Uploaded Logs", role: .destructive) {
					#if os(iOS)
					withAnimation {
						self.appStorageManager.uploadedLogs.removeAll()
						self.didClearUploadedLogs = true
					}
					#elseif os(macOS) // os(iOS)
					self.appStorageManager.uploadedLogs.removeAll()
					self.didClearUploadedLogs = true
					self.selectedLog = nil
					#endif // os(macOS)
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure that you want to clear the record of logs that have been uploaded from this device? This will only clear the logs locally; since uploaded logs are not tied to your device or your identity to protect your privacy, they can’t be deleted from the server.")
			}
			.confirmationDialog("Clear Uploaded Analytics Entries", isPresented: self.$doShowClearAnalyticsEntriesConfirmationDialog) {
				Button("Clear Uploaded Analytics Entries", role: .destructive) {
					#if os(iOS)
					withAnimation {
						self.appStorageManager.uploadedAnalyticsEntries.removeAll()
						self.didClearUploadedAnalyticsEntries = true
					}
					#elseif os(macOS) // os(iOS)
					self.appStorageManager.uploadedAnalyticsEntries.removeAll()
					self.didClearUploadedAnalyticsEntries = true
					self.selectedAnalyticsEntry = nil
					#endif // os(macOS)
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure that you want to clear the record of analytics entries that have been uploaded from this device? This will only clear the analytics entries locally; since no one has yet programmed a function to delete analytics entries, they can’t be deleted from the server.")
			}
			.onAppear {
				self.logUploadState = .waiting
			}
			.onChange(of: self.appStorageManager.uploadedLogs) { (newValue) in
				if !newValue.isEmpty {
					#if os(iOS)
					withAnimation {
						self.didClearUploadedLogs = false
					}
					#elseif os(macOS) // os(iOS)
					self.didClearUploadedLogs = false
					#endif // os(macOS)
				}
			}
			.onChange(of: self.appStorageManager.uploadedAnalyticsEntries) { (newValue) in
				if !newValue.isEmpty {
					#if os(iOS)
					withAnimation {
						self.didClearUploadedAnalyticsEntries = false
					}
					#elseif os(macOS) // os(iOS)
					self.didClearUploadedAnalyticsEntries = false
					#endif // os(macOS)
				}
			}
	}
	
	private func uploadLog() {
		#if os(iOS)
		withAnimation {
			self.logUploadState = .uploading
		}
		#elseif os(macOS) // os(iOS)
		self.logUploadState = .uploading
		#endif // os(macOS)
		Task {
			do {
				try await Logging.system.uploadLog()
				#if os(iOS)
				withAnimation {
					self.logUploadState = .uploaded
				}
				#elseif os(macOS) // os(iOS)
				self.logUploadState = .uploaded
				#endif // os(macOS)
			} catch {
				self.logUploadError = WrappedError(error)
				#log(system: Logging.system, level: .error, "Failed to upload log: \(error, privacy: .public)")
			}
		}
	}
	
}

#Preview {
	LoggingAnalyticsSettingsView()
		.environmentObject(AppStorageManager.shared)
		.task {
			AppStorageManager.shared.uploadedLogs = [
				Logging.Log(content: "Hello, world!")
			]
		}
}
