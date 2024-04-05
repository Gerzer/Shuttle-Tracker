//
//  AnnouncementsView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/27/24.
//

import SwiftUI

struct AnnouncementsView: View {
    
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
                                HStack {
                                    let isUnviewed = !self.appStorageManager.viewedAnnouncementIDs.contains(announcement.id)
                                    Circle()
                                        .fill(isUnviewed ? .blue : .clear)
                                        .frame(width: 10, height: 10)
                                    Text(announcement.subject)
                                        .bold(isUnviewed)
                                }
                            }
                        }
                    } else {
                        Text("There are no announcement.")
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
                Text("No announcement received")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
            }
                .navigationTitle("Announcements")
        }
        .task {
            self.announcements = await [Announcement].download()
        }
    }
}

#Preview {
    AnnouncementsView()
}
