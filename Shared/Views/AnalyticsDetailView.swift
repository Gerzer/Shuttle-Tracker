//
//  AnalyticsDetailView.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/17/23.
//

import STLogging
import SwiftUI

struct AnalyticsDetailView: View {
	
	let entry: Analytics.Entry
	
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .short
		dateFormatter.doesRelativeDateFormatting = true
		return dateFormatter
	}()
	
	private var jsonString: String? {
		get {
			do {
				return try self.entry.jsonString
			} catch {
				#log(system: Logging.system, level: .error, doUpload: true, "Failed to encode analytics entry: \(error, privacy: .public)")
				return nil
			}
		}
	}
	
	var body: some View {
		ScrollView {
			VStack {
				HStack {
					if #available(iOS 16, macOS 13, *) {
						Text(self.entry.id.uuidString)
							.font(.subheadline.monospaced().bold())
							.textSelection(.enabled)
					} else {
						Text(self.entry.id.uuidString)
							.font(.subheadline.monospaced().bold())
							.lineLimit(2)
					}
					Spacer()
				}
				Spacer()
				HStack {
					if let jsonString = self.jsonString {
						if #available(iOS 16.1, macOS 13, *) {
							Text(jsonString)
								.fontDesign(.monospaced)
								#if os(macOS)
								.textSelection(.enabled)
								#endif // os(macOS)
						} else {
							Text(jsonString)
								.font(.body.monospaced())
								#if os(macOS)
								.textSelection(.enabled)
								#endif // os(macOS)
						}
					} else {
						Text("The analytics entry can’t be displayed.")
							.italic()
					}
					Spacer()
				}
			}
				.padding(.horizontal)
		}
			#if os(iOS)
			.navigationTitle(self.dateFormatter.string(from: self.entry.date))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				if #available(iOS 16, *), let url = try? self.entry.writeToDisk() {
					ShareLink(item: url)
				}
			}
			#endif // os(iOS)
	}
}
