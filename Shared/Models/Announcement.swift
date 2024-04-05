//
//  Announcement.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/20/21.
//

import Foundation
import STLogging

final class Announcement: Decodable, Hashable, Identifiable, Sendable {
	
	enum ScheduleType: String, Decodable {
		
		case none = "none"
		
		case startOnly = "startOnly"
		
		case endOnly = "endOnly"
		
		case startAndEnd = "startAndEnd"
		
	}
	
	let id: UUID
	
	let subject: String
	
	let body: String
	
	let start: Date
	
	let end: Date
	
	let scheduleType: ScheduleType
	
	var startString: String {
		get {
			let formatter = RelativeDateTimeFormatter()
			formatter.formattingContext = .dynamic
			return formatter.localizedString(for: self.start, relativeTo: .now)
		}
	}
	
	var endString: String {
		get {
			let formatter = RelativeDateTimeFormatter()
			formatter.formattingContext = .dynamic
			return formatter.localizedString(for: self.end, relativeTo: .now)
		}
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
	static func == (lhs: Announcement, rhs: Announcement) -> Bool {
		return lhs.id == rhs.id
	}
	
}

extension Array where Element == Announcement {
	
	static func download() async -> [Announcement] {
		do {
			return try await API.readAnnouncements.perform(as: [Announcement].self)
				.filter { (announcement) in
					switch announcement.scheduleType {
					case .none:
						return true
					case .startOnly:
						return announcement.start <= .now
					case .endOnly:
						return announcement.end > .now
					case .startAndEnd:
						return announcement.start <= .now && announcement.end > .now
					}
				}
		} catch {
			#log(system: Logging.system, category: .api, level: .error, "Failed to download announcements: \(error, privacy: .public)")
			return []
		}
	}
	
}
