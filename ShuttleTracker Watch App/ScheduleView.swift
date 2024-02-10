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
            VStack(alignment: .leading, spacing: 8) {
                if let schedule = self.schedule {
                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("M").bold()
                                Text("\(schedule.content.monday.start) to \(schedule.content.monday.end)")
                            }
                            HStack {
                                Text("T").bold()
                                Text("\(schedule.content.tuesday.start) to \(schedule.content.tuesday.end)")
                            }
                            HStack {
                                Text("W").bold()
                                Text("\(schedule.content.wednesday.start) to \(schedule.content.wednesday.end)")
                            }
                            HStack {
                                Text("T").bold()
                                Text("\(schedule.content.thursday.start) to \(schedule.content.thursday.end)")
                            }
                            HStack {
                                Text("F").bold()
                                Text("\(schedule.content.friday.start) to \(schedule.content.friday.end)")
                            }
                            HStack {
                                Text("S").bold()
                                Text("\(schedule.content.saturday.start) to \(schedule.content.saturday.end)")
                            }
                            HStack {
                                Text("S").bold()
                                Text("\(schedule.content.sunday.start) to \(schedule.content.sunday.end)")
                            }
                        }
                    } header: {
                        Text("Schedule")
                            .font(.headline)
                    }
                }
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
