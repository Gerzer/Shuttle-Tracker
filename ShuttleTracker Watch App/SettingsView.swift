//
//  SettingsView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/19/24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject
    private var appStorageManager: AppStorageManager
    
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
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
