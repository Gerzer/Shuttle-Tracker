//
//  Announcement.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/20/21.
//

import Foundation

final class Announcement: Decodable, Identifiable {
	
	enum ScheduleType: String, Decodable {
		
		case none = "none"
		
		case startOnly = "startOnly"
		
		case endOnly = "endOnly"
		
		case startAndEnd = "startAndEnd"
		
	}
	
	let subject: String
	
	let body: String
	
	let start: Date
	
	let end: Date
	
	let scheduleType: ScheduleType
	
	var startString: String {
		get {
			let formatter = RelativeDateTimeFormatter()
			formatter.formattingContext = .dynamic
			if #available(iOS 15, macOS 12, *) {
				return formatter.localizedString(for: self.start, relativeTo: .now)
			} else {
				return formatter.localizedString(for: self.start, relativeTo: Date())
			}
		}
	}
	
	var endString: String {
		get {
			let formatter = RelativeDateTimeFormatter()
			formatter.formattingContext = .dynamic
			if #available(iOS 15, macOS 12, *) {
				return formatter.localizedString(for: self.end, relativeTo: .now)
			} else {
				return formatter.localizedString(for: self.end, relativeTo: Date())
			}
		}
	}
	
}

extension Array where Element == Announcement {
	
	@available(iOS 15, macOS 12, *) static func download() async -> [Announcement] {
		return await withCheckedContinuation { continuation in
			API.provider.request(.readAnnouncements) { (result) in
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601
				let announcements = try? result.value?
					.map([Announcement].self, using: decoder)
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
				continuation.resume(returning: announcements ?? [])
			}
		}
	}
	
}
