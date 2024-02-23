//
//  InfoView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/9/24.
//

import SwiftUI

struct InfoView: View {
    
    @EnvironmentObject
    private var appStorageManager : AppStorageManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Shuttle Tracker shows you the real-time locations of the Rensselaer campus shuttles.")
                    .font(.footnote)
                NavigationLink {
                    AnnouncementsSheet()
                } label: {
                    InformationTypeView(SFSymbol: .announcements,
                                        primaryColor: .white,
                                        secondaryColor: .red,
                                        name: "Announcements")
                }
                NavigationLink {
                    ScheduleView()
                } label: {
                    InformationTypeView(SFSymbol: .schedule,
                                        primaryColor: .white,
                                        secondaryColor: .orange,
                                        name: "Schedule")
                }
                NavigationLink {
                    SettingsView()
                        .environmentObject(self.appStorageManager)

                } label: {
                    InformationTypeView(SFSymbol: .settings,
                                        primaryColor: .white,
                                        secondaryColor: .gray,
                                        name: "Settings")
                }
                NavigationLink {
                    PrivacyView()
                } label: {
                    InformationTypeView(SFSymbol: .privacy,
                                        primaryColor: .white,
                                        secondaryColor: .blue,
                                        name: "Privacy")
                }
                NavigationLink {
                    PlusSheet(featureText: "Refreshing the map")
                } label: {
                    InformationTypeView(SFSymbol: .shuttleTrackerPlus,
                                        primaryColor: .white,
                                        secondaryColor: .clear,
                                        name: "Shuttle Tracker +")
                    .rainbow()
                }
            }
            .navigationTitle("Shuttle Tracker 🚐")
            .navigationBarTitleDisplayMode(.inline)
            .buttonStyle(.borderless)
        }
    }
}

#Preview {
    InfoView()
}
