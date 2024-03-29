//
//  ScheduleView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/9/24.
//

import SwiftUI

struct ScheduleView: View {
    
    @State private var schedule : Schedule?
    
    var body: some View {
        ScrollView {
            if let schedule = self.schedule {
                Group {
                    HStack {
                        let weekday = Calendar.current.component(.weekday, from: .now)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("M").bold(weekday == 2)
                            Text("T").bold(weekday == 3)
                            Text("W").bold(weekday == 4)
                            Text("T").bold(weekday == 5)
                            Text("F").bold(weekday == 6)
                            Text("S").bold(weekday == 7)
                            Text("S").bold(weekday == 1)
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(schedule.content.monday.start) to \(schedule.content.monday.end)")
                                .bold(weekday == 2)
                            Text("\(schedule.content.tuesday.start) to \(schedule.content.tuesday.end)")
                                .bold(weekday == 3)
                            Text("\(schedule.content.wednesday.start) to \(schedule.content.wednesday.end)")
                                .bold(weekday == 4)
                            Text("\(schedule.content.thursday.start) to \(schedule.content.thursday.end)")
                                .bold(weekday == 5)
                            Text("\(schedule.content.friday.start) to \(schedule.content.friday.end)")
                                .bold(weekday == 6)
                            Text("\(schedule.content.saturday.start) to \(schedule.content.saturday.end)")
                                .bold(weekday == 7)
                            Text("\(schedule.content.sunday.start) to \(schedule.content.sunday.end)")
                                .bold(weekday == 1)
                        }
                        Spacer()
                    }
                }
                .navigationTitle("Schedule")
            }
        }
        .onAppear {
            Task {
                self.schedule = await Schedule.download()
            }
        }
    }
}

#Preview {
    ScheduleView()
}
