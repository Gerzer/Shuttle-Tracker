//
//  InfoSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Andrew Emanuel on 10/5/21.
//

import SwiftUI

struct InfoSheet: View {
    @State private var schedule: Schedule?
    
    @AppStorage("ColorBlindMode") private var colorBlindMode = false
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Group{
                        Divider()
                        Rectangle().fill(Color.clear).frame(height: 10)
                        Text("OVERVIEW")
                            .font(.system(size: 16, weight: .light, design: .default))
                        Text("Shuttle Tracker shows you the real-time locations of the RPI campus shuttles, powered by crowd-sourced location data.")
                        Rectangle().fill(Color.clear).frame(height: 10)
                        Divider()
                    }
                    Group{
                        Rectangle().fill(Color.clear).frame(height: 10)
                        Text("SCHEDULE TIMES")
                            .font(.system(size: 16, weight: .light, design: .default))
                        if let schedule = self.schedule{ //only runs code in block if selfschedule != nil
                            let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                            let times: [Schedule.ScheduleContent.DaySchedule] = [schedule.content.monday, schedule.content.tuesday, schedule.content.wednesday, schedule.content.thursday, schedule.content.friday, schedule.content.saturday, schedule.content.sunday]

                            ForEach(0 ..< days.count) { (index) in
                                
                                Text("\(days[index]): \(times[index].start) to \(times[index].end)")
                            }
                        }
                        else{
                            Text("Weekdays: 7:00 AM to 11:45 PM")
                            Text("Saturday: 9:00 AM to 11:45 PM")
                            Text("Sunday: 9:00 AM to 8:00 PM")
                        }
                        
                        Rectangle().fill(Color.clear).frame(height: 10)
                        Divider()
                        
                    }
            
                    
                    
                    Group {
                        Rectangle().fill(Color.clear).frame(height: 10)
                        Text("INSTRUCTIONS")
                            .font(.system(size: 16, weight: .light, design: .default))
                        Text("The map automatically refreshes every 5 seconds")
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(.green)
                                Image(systemName: self.colorBlindMode ? "scope" : "bus")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50)
                            Text("Green buses provide high-quality location data")
                        }
                        .frame(height: 50)
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(.red)
                                Image(systemName: self.colorBlindMode ? "scope" : "bus")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50)
                            Text("Red buses provide low-quality location data")
                        }
                        .frame(height: 50)
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(.blue)
                                Image(systemName: "arrow.right.to.line.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50)
                            Text("Tap \"Board Bus\" when boarding")
                        }
                        .frame(height: 50)
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(.blue)
                                Image(systemName: "arrow.left.to.line.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50)
                            Text("Tap \"Leave Bus\" when departing")
                        }
                        .frame(height: 50)
                        
                        
                        HStack {
                            Text("NOTE: YOU MUST BE WITHIN 20 METERS OF A STOP TO BOARD A BUS")
                        }
                        .frame(height: 40)
                        .font(.system(size: 12, weight: .light, design: .default))
                        Rectangle().fill(Color.clear).frame(height: 5)
                        Divider()
                    }
                    
                    Group{
                        Rectangle().fill(Color.clear).frame(height: 5)
                        Text("PRIVACY")
                            .font(.system(size: 16, weight: .light, design: .default))
                        Text("Shuttle Tracker sends your location data to our server only when you tap “Board Bus” and stops sending these data when you tap “Leave Bus”. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, or any other identifying information. We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates.") .background(Color.white)
                        Rectangle().fill(Color.clear).frame(height: 5)
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Shuttle Tracker 🚐")
            .toolbar {
                ToolbarItem {
                    CloseButton()
                }
            }
            .onAppear {
                if #available(iOS 15, *) {
                    Task {
                        self.schedule = await [Schedule].download()
                    }
                }
            }
        }
    }
    
    
}

struct InfoSheetPreviews: PreviewProvider {
    
    static var previews: some View {
        InfoSheet()
        Group {
            InfoSheet()
        }
    }
    
}
