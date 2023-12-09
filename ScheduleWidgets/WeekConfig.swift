//
//  WeekConfig.swift
//  macOS
//
//  Created by Yi Chen on 12/8/23.
//

import SwiftUI

import SwiftUI

extension Color {
    static let paleYellow   = Color(red: 252/255, green: 225/255, blue: 121/255)
    static let palePink     = Color(red: 254/255, green: 138/255, blue: 138/255)
    static let darkGreen    = Color(red: 0/255, green: 67/255, blue: 13/255)
    static let paleGreen    = Color(red: 163/255, green: 230/255, blue: 127/255)
    static let paleBlue     = Color(red: 139/255, green: 229/255, blue: 233/255)
    static let skyBlue      = Color(red: 103/255, green: 155/255, blue: 197/255)
    static let paleOrange   = Color(red: 197/255, green: 161/255, blue: 103/255)
    static let darkOrange   = Color(red: 172/255, green: 110/255, blue: 16/255)
    static let paleRed      = Color(red: 174/255, green: 80/255, blue: 80/255)
    static let paleBrown    = Color(red: 124/255, green: 102/255, blue: 85/255)
}


struct WeekConfig {
    let backgroundColor: Color
    let emojiText: String
    let weekdayTextColor: Color
    let ScheduleColor: Color

    static func determineConfig(from date: Date) -> WeekConfig {
        let monthInt = Calendar.current.component(.weekday, from: date) + Int.random(in: 0..<5)

        switch monthInt {
        case 1:
            return WeekConfig(backgroundColor: .gray,
                               emojiText: "⛄️",
                               weekdayTextColor: .black.opacity(0.6),
                               ScheduleColor: .white.opacity(0.8))
        case 2:
            return WeekConfig(backgroundColor: .palePink,
                               emojiText: "❤️",
                               weekdayTextColor: .black.opacity(0.5),
                               ScheduleColor: .pink.opacity(0.8))
        case 3:
            return WeekConfig(backgroundColor: .paleGreen,
                               emojiText: "☘️",
                               weekdayTextColor: .black.opacity(0.7),
                               ScheduleColor: .darkGreen.opacity(0.8))
        case 4:
            return WeekConfig(backgroundColor: .paleBlue,
                               emojiText: "☔️",
                               weekdayTextColor: .black.opacity(0.5),
                               ScheduleColor: .purple.opacity(0.8))
        case 5:
            return WeekConfig(backgroundColor: .paleYellow,
                               emojiText: "🌺",
                               weekdayTextColor: .black.opacity(0.5),
                               ScheduleColor: .pink.opacity(0.7))
        case 6:
            return WeekConfig(backgroundColor: .skyBlue,
                               emojiText: "🌤",
                               weekdayTextColor: .black.opacity(0.5),
                               ScheduleColor: .paleYellow.opacity(0.8))
        case 7:
            return WeekConfig(backgroundColor: .blue,
                               emojiText: "🏖",
                               weekdayTextColor: .black.opacity(0.5),
                               ScheduleColor: .paleBlue.opacity(0.8))
        case 8:
            return WeekConfig(backgroundColor: .paleOrange,
                               emojiText: "☀️",
                               weekdayTextColor: .black.opacity(0.5),
                               ScheduleColor: .darkOrange.opacity(0.8))
        case 9:
            return WeekConfig(backgroundColor: .paleRed,
                               emojiText: "🍁",
                               weekdayTextColor: .black.opacity(0.5),
                               ScheduleColor: .paleYellow.opacity(0.9))
        case 10:
            return WeekConfig(backgroundColor: .black,
                               emojiText: "👻",
                               weekdayTextColor: .white.opacity(0.6),
                               ScheduleColor: .orange.opacity(0.8))

        case 12:
            return WeekConfig(backgroundColor: .paleRed,
                               emojiText: "🎄",
                               weekdayTextColor: .white.opacity(0.9),
                               ScheduleColor: .darkGreen.opacity(0.7))
        default:
            return WeekConfig(backgroundColor: .gray,
                               emojiText: "📅",
                               weekdayTextColor: .black.opacity(0.6),
                               ScheduleColor: .white.opacity(0.8))
        }
    }
}
