//
//  AnnouncementDetailView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 3/1/24.
//

import SwiftUI

struct AnnouncementDetailView: View {
    
    let announcement: Announcement
    
    @Binding
    private(set) var didResetViewedAnnouncements: Bool
    
    @EnvironmentObject
    private var appStorageManager: AppStorageManager
    
    var body: some View {
        VStack {
            HStack {
                Text(announcement.subject)
                    .bold()
                Spacer()
                Text(announcement.startString)
            }
            Text(announcement.body)
        }
    }
    
    init(announcement: Announcement, didResetViewedAnnouncements: Binding<Bool> = .constant(false)) {
        self.announcement = announcement
        self._didResetViewedAnnouncements = didResetViewedAnnouncements
    }
    
}

//#Preview {
//    AnnouncementDetailView(announcement: Anno,
//                           didResetViewedAnnouncements: .constant(true))
//}
