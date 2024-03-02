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
}

//#Preview {
//    AnnouncementDetailView(announcement: , didResetViewedAnnouncements: <#Binding<Bool>#>)
//}
