//
//  AnalyticsDetailView.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/17/23.
//

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
			} catch let error {
				Logging.withLogger(doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to encode analytics entry: \(error, privacy: .public)")
				}
				return nil
			}
		}
	}
	
	var body: some View {
		ScrollView {
			VStack {
				HStack {
					if let id = self.entry.id {
						if #available(iOS 16, macOS 13, *) {
							Text(id.uuidString)
								.font(.subheadline.monospaced().bold())
								.textSelection(.enabled)
						} else {
							Text(id.uuidString)
								.font(.subheadline.monospaced().bold())
								.lineLimit(2)
						}
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

struct AnalyticsDetailViewPreviews: PreviewProvider {
	
	@State
	static var entry: Analytics.Entry? = nil
	
	static var previews: some View {
		NavigationView {
			if let entry = self.entry {
				AnalyticsDetailView(entry: entry)
			}
		}
			.onAppear {
				Task {
					self.entry = await Analytics.Entry(.permissionsSheetOpened)
				}
			}
	}
	
}
