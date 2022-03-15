//
//  Schedule.swift
//  Shuttle Tracker
//
//  Created by Emily K. Ngo on 2/15/22.
//

import Foundation
final class Schedule: Decodable, Identifiable {
    internal init(name: String, start: Date, end: Date, content: Schedule.ScheduleContent) {
        self.name = name
        self.start = start
        self.end = end
        self.content = content
    }
    let name: String
    
    let start: Date
    
    let end: Date
    
    let content: ScheduleContent
    
    struct ScheduleContent: Decodable {
        struct DaySchedule: Decodable{
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
    
    //let scheduleType: ScheduleType
    
}

extension Array where Element == Schedule {
    @available(iOS 15, macOS 12, *) static func download() async -> Schedule? {
        return await withCheckedContinuation { continuation in
            API.provider.request(.schedule) { (result) in //get schedule api call
                let decoder = JSONDecoder() //process the JSON file
                decoder.dateDecodingStrategy = .iso8601
                let current_schedules = try? result.value?
                    .map([Schedule].self, using: decoder)
                    .first(where: { schedule in //.first calls the block of code
                        return schedule.start <= Date.now && schedule.end >= Date.now
                    })
                continuation.resume(returning: current_schedules)
            }
        }
    }
}
