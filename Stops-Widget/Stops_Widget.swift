//
//  Stops_Widget.swift
//  Stops-Widget
//
//  Created by Yi Chen on 12/8/23.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct Stops_WidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing:2){
            HStack(spacing: 2){
                ZStack{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color(UIColor.red))
                        .frame(width: 250, height: 100)
                        .border(.white)
                    Text("Student Union")
                        .foregroundStyle(.white)
                    
                }
                ZStack{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color(UIColor.red))
                        .frame(width: 250, height: 100)
                        .border(.white)
                    Text("B-Lot")
                        .foregroundStyle(.white)
                }
                
            }
            HStack(spacing: 2){
                ZStack{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color(UIColor.red))
                        .frame(width: 250, height: 100)
                        .border(.white)
                    Text("Colonie")
                        .foregroundStyle(.white)
                }
                ZStack{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color(UIColor.red))
                        .frame(width: 250, height: 100)
                        .border(.white)
                    Text("E-Lot")
                        .foregroundStyle(.white)
                }
                
            }
            HStack(spacing: 2){
                ZStack{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color(UIColor.red))
                        .frame(width: 250, height: 100)
                        .border(.white)
                    Text("Stacwyck")
                        .foregroundStyle(.white)
                }
                ZStack{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color(UIColor.red))
                        .frame(width: 250, height: 100)
                        .border(.white)
                    Text("Bryckwyck")
                        .foregroundStyle(.white)
                }
                
            }
            HStack(spacing: 2){
                ZStack{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color(UIColor.red))
                        .frame(width: 250, height: 100)
                        .border(.white)
                    Text("Biltman")
                        .foregroundStyle(.white)
                }   }
            ZStack{
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .fill(Color(UIColor.red))
                    .frame(width: 250, height: 100)
                    .border(.white)
                Text("City Station")
                    .foregroundStyle(.white)
            }
            ZStack{
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .fill(Color(UIColor.red))
                    .frame(width: 250, height: 100)
                    .border(.white)
                Text("Tibits Avenue")
                    .foregroundStyle(.white)
            }
            
        }
        HStack(spacing: 2){
            ZStack{
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .fill(Color(UIColor.red))
                    .frame(width: 250, height: 100)
                    .border(.white)
                Text("Academy Hall")
                    .foregroundStyle(.white)
                
            }
            
        }
    }
    
    
    struct Stops_Widget: Widget {
        let kind: String = "Stops_Widget"
        
        var body: some WidgetConfiguration {
            AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
                Stops_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
            
            
        }
    }
}
extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}


