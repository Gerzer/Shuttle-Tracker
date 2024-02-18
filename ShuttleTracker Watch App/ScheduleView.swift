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
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("M").bold()
                            Text("T").bold()
                            Text("W").bold()
                            Text("T").bold()
                            Text("F").bold()
                            Text("S").bold()
                            Text("S").bold()
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(schedule.content.monday.start) to \(schedule.content.monday.end)")
                            Text("\(schedule.content.tuesday.start) to \(schedule.content.tuesday.end)")
                            Text("\(schedule.content.wednesday.start) to \(schedule.content.wednesday.end)")
                            Text("\(schedule.content.thursday.start) to \(schedule.content.thursday.end)")
                            Text("\(schedule.content.friday.start) to \(schedule.content.friday.end)")
                            Text("\(schedule.content.saturday.start) to \(schedule.content.saturday.end)")
                            Text("\(schedule.content.sunday.start) to \(schedule.content.sunday.end)")
                        }
                        Spacer()
                    }
                } header: {
                    Text("Schedule")
                        .font(.headline)
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
