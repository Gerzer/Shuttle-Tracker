//
//  AnalyticsDetailView.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/17/23.
//

import SwiftUI

struct AnalyticsDetailView: View {
	
	let entry: Analytics.AnalyticsEntry
	
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .short
		dateFormatter.doesRelativeDateFormatting = true
		return dateFormatter
	}()
	
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
					if #available(iOS 16.1, macOS 13, *) {
						Text(Analytics.toJSONString(self.entry))
							.fontDesign(.monospaced)
							#if os(macOS)
							.textSelection(.enabled)
							#endif // os(macOS)
					} else {
						Text(Analytics.toJSONString(self.entry))
							.font(.body.monospaced())
							#if os(macOS)
							.textSelection(.enabled)
							#endif // os(macOS)
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
	static var entry: Analytics.AnalyticsEntry? = nil
	
	static var previews: some View {
		NavigationView {
			if let entry = entry {
				AnalyticsDetailView(entry: entry)
			}
		}
			.onAppear {
				Task {
					entry = await Analytics.AnalyticsEntry(.permissionsSheetOpened)
				}
			}
	}
	
}
