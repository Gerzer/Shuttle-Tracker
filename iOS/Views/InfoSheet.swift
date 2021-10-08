//
//  InfoSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Andrew Emanuel on 10/5/21.
//

import SwiftUI

struct InfoSheet: View {
    
    @Binding private(set) var parentSheetType: ContentView.SheetType?
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text("Shuttle Tracker 🚐")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.bottom)
                    Text("Shuttle Tracker shows you the real-time locations of the RPI campus shuttles, powered by crowd-sourced location data.")
                        .padding(.bottom)
                    Text("Schedule")
                        .font(.headline)
                    Text("Monday - Friday, 7:00 a.m. - 11:45 p.m.")
                    Text("Saturday 9:00 a.m. - 11:45 p.m.")
                    Text("Sunday 9:00 a.m. - 8:00 p.m. ")
                        .padding(.bottom)
                    Text("Instructions")
                        .font(.headline)
                    Text("The map is automatically refreshed every 5 seconds. Green buses have high-quality location data and red buses have low-quality location data. When boarding tap “Board Bus“ and when getting off tap “Leave Bus“. You must be within 10 meters of a stop to board a bus.")
                        .padding(.bottom)
                    Text("Privacy")
                        .font(.headline)
                    Text("Shuttle Tracker sends your location data every 5 seconds to our server only when you tap “Board Bus” and stops sending this data when you tap “Leave Bus”. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, or any other identifying information. We continuously purge location data that are more than 15 minutes old from our server.")
                }
            }
        }
            .padding()
    }
}

struct InfoSheet_Previews: PreviewProvider {
    static var previews: some View {
        InfoSheet(parentSheetType: .constant(.info))
    }
}
