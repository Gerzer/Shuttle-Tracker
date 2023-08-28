//
//  Announcement.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/20/21.
//

import Foundation

final class Announcement: Decodable, Identifiable, Sendable {
	
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
			Logging.withLogger(for: .api) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to download announcements: \(error, privacy: .public)")
			}
			return []
		}
	}
	
}
