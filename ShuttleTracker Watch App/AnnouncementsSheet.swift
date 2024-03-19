//
//  AnnouncementsSheet.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 3/1/24.
//

import SwiftUI

struct AnnouncementsSheet: View {
    
    @State
    private var announcements: [Announcement]?
        
    @State
    private var didResetViewedAnnouncements = false
    
    @EnvironmentObject
    private var appStorageManager: AppStorageManager
    
    var body: some View {
        NavigationView {
            Group {
                if let announcements = self.announcements {
                    if announcements.count > 0 {
                        List(announcements) { (announcement) in
                            NavigationLink {
                                AnnouncementDetailView(
                                    announcement: announcement,
                                    didResetViewedAnnouncements: self.$didResetViewedAnnouncements
                                )
                            } label: {
                                let isUnviewed = !self.appStorageManager.viewedAnnouncementIDs.contains(announcement.id)
                                VStack(alignment: .leading) {
                                    HStack {
                                        if isUnviewed {
                                            Circle()
                                                .fill(.blue)
                                                .frame(width: 10, height: 10)
                                        }
                                        Text(announcement.subject)
                                            .font(.headline)
                                            .lineLimit(1)
                                    }
                                    Text(announcement.body)
                                        .lineLimit(2)
                                }
                                .bold(isUnviewed)
                                .padding()
                            }
                        }
                    } else {
                        Text("There are no announcements.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                } else {
                    ProgressView("Loading")
                        .font(.callout)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
                .navigationTitle("Announcements")
        }
        .task {
            self.announcements = await [Announcement].download()
        }
    }
}

#Preview {
    AnnouncementsSheet()
}
