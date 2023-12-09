//
//  ScheduleWidgets.swift
//  ScheduleWidgets
//
//  Created by Yi Chen on 12/8/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        // Generate a timeline consisting of seven entries an day apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DayEntry: TimelineEntry {
    let date: Date

}

struct ScheduleWidgetsEntryView : View {
    var entry: DayEntry
    var config: WeekConfig
    
    init(entry: DayEntry) {
        self.entry = entry
        self.config = WeekConfig.determineConfig(from: entry.date)
    }
    var body: some View {
        VStack{
            HStack(spacing: 4){
                Text(config.emojiText)
                    .font(.title)
                Text(entry.date.weekdayFormat)
                    .font(.title3)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(config.weekdayTextColor)
               
            }
            Spacer()
            let weekday = entry.date.weekdayFormat
            switch weekday{
            case "Monday":
                Text("7:00 AM to 12:00 AM")
                    .font(.system(size:20, weight:.heavy))
                    .foregroundStyle(config.ScheduleColor)
                    .padding(.bottom)
            case "Tuesday":
                Text("7:00 AM to 12:00 AM")
                    .font(.system(size:20, weight:.heavy))
                    .foregroundStyle(config.ScheduleColor)
                    .padding(.bottom)
            case "Wensday":
                Text("7:00 AM to 12:00 AM")
                    .font(.system(size:20, weight:.heavy))
                    .foregroundStyle(config.ScheduleColor)
                    .padding(.bottom)
            case "Thursday":
                Text("7:00 AM to 12:00 AM")
                    .font(.system(size:20, weight:.heavy))
                    .foregroundStyle(config.ScheduleColor)
                    .padding(.bottom)
            case "Friday":
                Text("7:00 AM to 12:00 AM")
                    .font(.system(size:20, weight:.heavy))
                    .foregroundStyle(config.ScheduleColor)
                    .padding(.bottom)
            case "Staturyday":
                Text("9:00 AM to 8:00 PM")
                    .font(.system(size:20, weight:.heavy))
                    .foregroundStyle(config.ScheduleColor)
                    .padding(.bottom)
            default:
                EmptyView()
            }
        }
    }
}

struct ScheduleWidgets: Widget {
    let kind: String = "ScheduleWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                let config : WeekConfig = WeekConfig.determineConfig(from: entry.date)
                ScheduleWidgetsEntryView(entry: entry)
                    .containerBackground(config.backgroundColor, for: .widget)
            } else {
                ScheduleWidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

extension Date{
    var weekdayFormat: String {
        self.formatted(.dateTime.weekday(.wide))
    }
}

#Preview(as: .systemSmall) {
    ScheduleWidgets()
} timeline: {
    DayEntry(date: .now)
    DayEntry(date: .now)
}
