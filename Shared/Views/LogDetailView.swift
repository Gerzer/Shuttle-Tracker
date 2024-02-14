//
//  LogDetailView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 11/19/22.
//

import SwiftUI

struct LogDetailView: View {
	
	let log: Logging.Log
	
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
					if #available(iOS 16, macOS 13, *) {
						Text("\(self.log.id.uuidString)")
							.font(.subheadline.monospaced().bold())
							.textSelection(.enabled)
					} else {
						Text("\(self.log.id.uuidString)")
							.font(.subheadline.monospaced().bold())
							.lineLimit(2)
					}
					Spacer()
				}
				Spacer()
				HStack {
					if #available(iOS 16.1, macOS 13, *) {
						Text(self.log.content)
							.fontDesign(.monospaced)
							#if os(macOS)
							.textSelection(.enabled)
							#endif // os(macOS)
					} else {
						Text(self.log.content)
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
			.navigationTitle(self.dateFormatter.string(from: self.log.date))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				if #available(iOS 16, *), let url = try? self.log.writeToDisk() {
					ShareLink(item: url)
				}
			}
			#endif // os(iOS)
	}
	
}

#Preview {
	NavigationView {
		LogDetailView(log: Logging.Log(content: "This is a test."))
	}
}
