//
//  NotificationsSettingsView.swift
//  Shuttle Tracker
//
//  Created by Yi Chen on 12/8/23.
//

import SwiftUI
import CoreLocation

@preconcurrency
import UserNotifications

struct NotificationsSettingsView: View {
    
    @State
    private var notificationAuthorizationStatus: UNAuthorizationStatus?
    
    @State
    private var notificationScale: CGFloat = 0
    
    @State
    
    private var has_authorized: Bool = false
    
    @EnvironmentObject
    private var appStorageManager: AppStorageManager
    
    @Environment(\.openURL)
    private var openURL
    
    
    var body: some View {
        
        VStack {
            if let notificationAuthorizationStatus = self.notificationAuthorizationStatus {
                Group {
                    switch notificationAuthorizationStatus {
                    case .authorized, .ephemeral, .provisional:
                        Form{
                            Section{
                                Toggle("Automatic Board Bus", isOn: self.appStorageManager.$automaticBoardNotification)
                            }
                        footer: {
                            Text("Disable automatic board bus enable notification delivery.")
                        }
                        }
                    case .denied:
                        HStack(alignment: .top) {
                            Image(systemName: SFSymbol.permissionDenied.systemName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text("Notifications")
                                    .font(.headline)
                                if case (.authorizedAlways, .fullAccuracy) = (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
                                    Text(try! AttributedString(markdown: "Enable **Allow Notifications** in Settings."))
                                        .accessibilityShowsLargeContentViewer()
                                } else {
                                    Text("You haven’t yet enabled notification delivery.")
                                        .accessibilityShowsLargeContentViewer()
                                }
                            }
                        }
                    case .notDetermined:
                        HStack(alignment: .top) {
                            Image(systemName: SFSymbol.permissionNotDetermined.systemName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text("Notifications")
                                    .font(.headline)
                                if case (.authorizedAlways, .fullAccuracy) = (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
                                    Text(try! AttributedString(markdown: "Tap **Continue** and then enable notification delivery."))
                                        .accessibilityShowsLargeContentViewer()
                                } else {
                                    Text("You haven’t yet enabled notification delivery.")
                                        .accessibilityShowsLargeContentViewer()
                                }
                            }
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .scaleEffect(self.notificationScale)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                        self.notificationScale = 1.3
                    }
                    withAnimation(.easeOut(duration: 0.2).delay(1)) {
                        self.notificationScale = 1
                    }
                }
                
            }
        }
        .symbolRenderingMode(.multicolor)
        .task {
            self.notificationAuthorizationStatus = await UNUserNotificationCenter
                .current()
                .notificationSettings()
                .authorizationStatus
            if let notificationAuthorizationStatus = self.notificationAuthorizationStatus {
                switch notificationAuthorizationStatus {
                case .authorized, .ephemeral, .provisional:
                    has_authorized = true
                default:
                    break
                }
            }
        }
        Spacer()
       
        
        
        Button{
            if let notificationAuthorizationStatus = self.notificationAuthorizationStatus {
                switch notificationAuthorizationStatus {
                case .authorized, .ephemeral, .provisional:
                    break
                case .denied:
                    if #available(iOS 16, *) {
                        self.openURL(URL(string: UIApplication.openNotificationSettingsURLString)!)
                    } else {
                        self.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                case .notDetermined:
                    Task {
                        do {
                            try await UNUserNotificationCenter.requestDefaultAuthorization()
                        } catch {
                            Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
                                logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Notification authorization request failed: \(error, privacy: .public)")
                            }
                        }
                    }
                @unknown default:
                    fatalError()
                }
            } else {
                Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
                    logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Notification authorization status is not available")
                }}
            
                }label:{
                    ZStack{
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.red)
                            .frame(width: 400, height: has_authorized ? 0: 50)
                        Text("Continue")
                            .bold()
                            .foregroundStyle(.white)
                            .font(.headline)
                    }
                }
            .navigationTitle("Notifications")
            .toolbar{
                ToolbarItem{
                    CloseButton()
                }
            }
    }
    
}

struct NotificationSettingsViewPreviews: PreviewProvider {
    
    static var previews: some View{
        NotificationsSettingsView()
    }
}
