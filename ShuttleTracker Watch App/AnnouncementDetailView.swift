//
//  AnnouncementDetailView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 3/1/24.
//

import SwiftUI
import UserNotifications
import STLogging

struct AnnouncementDetailView: View {
    
    let announcement: Announcement
    
    @Binding
    private(set) var didResetViewedAnnouncements: Bool
    
    @EnvironmentObject
    private var appStorageManager: AppStorageManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(announcement.subject)
                .font(.headline)
            Text(announcement.body)
            HStack {
                switch self.announcement.scheduleType {
                case .none:
                    EmptyView()
                case .startOnly:
                    Text("Posted \(self.announcement.startString)")
                case .endOnly:
                    Text("Expires \(self.announcement.endString)")
                case .startAndEnd:
                    Text("Posted \(self.announcement.startString); expires \(self.announcement.endString)")
                }
                Spacer()
            }
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .task {
            self.didResetViewedAnnouncements = false
            self.appStorageManager.viewedAnnouncementIDs.insert(self.announcement.id)
            
            do {
                try await UNUserNotificationCenter.updateBadge()
            } catch {
                #log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Failed to update badge: \(error, privacy: .public)")
            }
            
            do {
                try await Analytics.upload(eventType: .announcementViewed(id: self.announcement.id))
            } catch {
                #log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to upload analytics entry: \(error, privacy: .public)")
            }
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
