//
//  AnnouncementToast.swift
//  Shuttle Tracker
//
//  Created by Yi Chen on 12/4/23.
//


import SwiftUI
import UserNotifications

struct AnnouncementToast : View{
    
    let announcement : Announcement
    
    @EnvironmentObject
    private var viewState: ViewState
    
    @EnvironmentObject
    private var appStorageManager: AppStorageManager
    
    private var HeadlineText: String{
        get{
            return "📢 " + self.announcement.subject
        }
    }
    var body: some View{
        Toast(self.HeadlineText, item: self.$viewState.toastType){ (_, _) in
            ScrollView{
                HStack{
                    Text(self.announcement.body)
                    Spacer()
                }
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
            .padding(.horizontal)
            .frame(maxHeight: 200)
            .task {
                self.appStorageManager.viewedAnnouncementIDs.insert(self.announcement.id)
                do {
                    try await UNUserNotificationCenter.updateBadge()
                } catch let error {
                    Logging.withLogger(for: .apns, doUpload: true) { (logger) in
                        logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to update badge: \(error, privacy: .public)")
                    }
                }
                
                do {
                    try await Analytics.upload(eventType: .announcementViewed(id: self.announcement.id))
                } catch {
                    Logging.withLogger(for: .api) { (logger) in
                        logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics entry: \(error, privacy: .public)")
                    }
                }
            }
        }
    }

    
}
