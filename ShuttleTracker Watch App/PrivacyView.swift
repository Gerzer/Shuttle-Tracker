//
//  PrivacyView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/23/24.
//

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Section {
                    Text("Shuttle Tracker sends your location data to our server only when Board Bus is activated and stops sending these data when Board Bus is deactivated. You can activate Board Bus manually by tapping “Board Bus” or automatically by positioning your device within Bluetooth range of a Shuttle Tracker Node device on a bus if you opted in to the Shuttle Tracker Network. You can deactivate Board Bus manually by tapping “Leave Bus” or automatically by positioning your device out of Bluetooth range of a Shuttle Tracker Node device on a bus if you opted in to the Shuttle Tracker Network. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, RIN, or any other information that might identify you or your device. We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates. Even if you opt in to the Shuttle Tracker Network, we never track your location unless you manually activate Board Bus or physically board a bus. Your device might alert you to Shuttle Tracker’s location monitoring in the background even when Shuttle Tracker isn’t actually tracking your location. This is due to a system limitation; Shuttle Tracker occasionally scans for Shuttle Tracker Node devices in the  background, and your device might show that activity as location tracking. The results of these scans never leave your device, and we only start collecting location data if a scan indicates that you’re physically on a bus.")
                        .font(.footnote)
                        .padding(.bottom)
                        .lineLimit(1, reservesSpace: true)
                } header: {
                    Text("Location")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    PrivacyView()
}
