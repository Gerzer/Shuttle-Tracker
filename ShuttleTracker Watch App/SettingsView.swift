//
//  SettingsView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/19/24.
//

import SwiftUI
import UserNotifications
import STLogging

struct SettingsView: View {
    
    @EnvironmentObject
    private var appStorageManager: AppStorageManager
    
    @State
    private var didResetViewedAnnouncements = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    ZStack {
                        Circle()
                            .fill(.green)
                        Image(systemName: self.appStorageManager.colorBlindMode ? SFSymbol.colorBlindHighQualityLocation.systemName : SFSymbol.bus.systemName)
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.white)
                    }
                    .frame(width: 30)
                    .animation(.default, value: self.appStorageManager.colorBlindMode)
                    Toggle("Color-Blind Mode", isOn: self.appStorageManager.$colorBlindMode)
                }
                .frame(height: 30)
            } footer: {
                Text("Modifies bus markers so that they’re distinguishable by icon in addition to color.")
            }
            
            Section {
                Button(role: .destructive) {
                    Task {
                        do {
                            try await UNUserNotificationCenter.updateBadge()
                        } catch {
                            #log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Failed to update badge: \(error, privacy: .public)")
                        }
                    }
                    withAnimation {
                        self.appStorageManager.viewedAnnouncementIDs.removeAll()
                        self.didResetViewedAnnouncements = true
                    }
                } label: {
                    HStack {
                        Text("Reset Viewed Announcements")
                        if self.didResetViewedAnnouncements {
                            Spacer()
                            Text("✓")
                        }
                    }
                }
            } footer: {
                Text("Pressing this button resets all current live announcements to unviewed.")
            }
            .disabled(self.appStorageManager.viewedAnnouncementIDs.isEmpty)

            Section {
                // URL.FormatStyle’s integration with TextField seems to be broken currently, so we fall back on our custom URL format style
                TextField("Server Base URL", value: self.appStorageManager.$baseURL, format: .compatibilityURL)
                    .labelsHidden()
                    .scrollDismissesKeyboard(.interactively)
            } header: {
                Text("Server Base URL")
            } footer: {
                Text("The base URL for the API server. Changing this setting could make the rest of the app stop working properly.")
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
