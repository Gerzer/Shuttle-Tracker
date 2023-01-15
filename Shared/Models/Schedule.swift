//
//  Schedule.swift
//  Shuttle Tracker
//
//  Created by Emily Ngo on 2/15/22.
//

import Foundation

final class Schedule: Decodable, Identifiable {
	
	struct Content: Decodable {
		
		struct DaySchedule: Decodable {
			
			let start: String
			
			let end: String
			
		}
		
		let monday: DaySchedule
		
		let tuesday: DaySchedule
		
		let wednesday: DaySchedule
		
		let thursday: DaySchedule
		
		let friday: DaySchedule
		
		let saturday: DaySchedule
		
		let sunday: DaySchedule
		
	}
	
	let name: String
	
	let start: Date
	
	let end: Date
	
	let content: Content
	
	init(name: String, start: Date, end: Date, content: Schedule.Content) {
		self.name = name
		self.start = start
		self.end = end
		self.content = content
	}
	
	static func download() async -> Schedule? {
		do {
			return try await API.readSchedule.perform(as: [Schedule].self)
				.first { (schedule) in
					return schedule.start <= Date.now && schedule.end >= Date.now
				}
		} catch let error {
			Logging.withLogger(for: .api, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to download schedule: \(error, privacy: .public)")
			}
			return nil
		}
	}
	
}
