//
//  ContentView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 1/30/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var schedule : Schedule?
    
    var body: some View {
        ScrollView {
            Text("schedule")
            if let schedule {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Monday")
                        Text("Tuesday")
                        Text("Wednesday")
                        Text("Thursday")
                        Text("Friday")
                        Text("Saturday")
                        Text("Sunday")
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
            }
        }
    }
}
    
#Preview {
    ContentView()
}
