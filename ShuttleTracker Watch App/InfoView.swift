//
//  InfoView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/9/24.
//

import SwiftUI

struct InfoView: View {
    
    @State var stack = [Int]()
    
    var body: some View {
        NavigationStack(path: $stack) {
            ScrollView {
                Text("Shuttle Tracker shows you the real-time locations of the Rensselaer campus shuttles.")
                    .font(.footnote)
                NavigationLink {
                    AnnouncementsSheet()
                } label: {
                    InformationTypeView(SFSymbol: .announcements,
                                        iconColor: .blue,
                                        name: "Announcements")
                }
                NavigationLink {
                    ScheduleView()
                } label: {
                    InformationTypeView(SFSymbol: .schedule,
                                        iconColor: .orange,
                                        name: "Schedule")
                }
                NavigationLink {
                    PlusSheet(featureText: "Refreshing the map")
                } label: {
                    InformationTypeView(SFSymbol: .shuttleTrackerPlus ,
                                        iconColor: .white,
                                        name: "Shuttle Tracker +")
                    .rainbow()
                }
            }
            .buttonStyle(.borderless)
        }
    }
}

#Preview {
    InfoView()
}
