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
	
	@available(iOS 15, macOS 12, *) static func download() async -> Schedule? {
		return await withCheckedContinuation { (continuation) in
			API.provider.request(.schedule) { (result) in
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601
				let schedule = try? result.value?
					.map([Schedule].self, using: decoder)
					.first { (schedule) in
						return schedule.start <= Date.now && schedule.end >= Date.now
					}
				continuation.resume(returning: schedule)
			}
		}
	}
	
}
