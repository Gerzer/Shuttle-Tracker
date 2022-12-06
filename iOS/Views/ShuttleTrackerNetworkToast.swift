//
//  ShuttleTrackerNetworkToast.swift
//  iOS
//
//  Created by John Foster on 12/1/22.
//
import Foundation

import SwiftUI

struct ShuttleTrackerNetworkToast: View {

    @EnvironmentObject private var viewState: ViewState
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var sheetStack: SheetStack

    var body: some View {
        Toast("We cant see you!") {
            withAnimation {
                self.viewState.toastType = nil
            }
        } content: {
            Text("Enable location services for optimal usage of the Shuttle Tracker Network.")
            
            VStack{
                Button{
                    
                    switch (LocationUtilities.locationManager.authorizationStatus, LocationUtilities.locationManager.accuracyAuthorization) {
                                           case (.authorizedAlways, .fullAccuracy), (.authorizedWhenInUse, .fullAccuracy):
                                              break
                                           case (.restricted, _), (.denied, _):
                                               let url = try! UIApplication.openSettingsURLString.asURL()
                                               self.openURL(url)
                                           case (.notDetermined, _):
                                               LocationUtilities.locationManager.requestAlwaysAuthorization()
                                           case (_, .reducedAccuracy):
                                               Task {
                                                   do {
                                                       try await LocationUtilities.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "BoardBus")
                                                   } catch let error {
                                                       print("[Network_toast body] Full-accuracy location authorization request error: \(error.localizedDescription)")
                                                   }
                                               }
                                           @unknown default:
                                               fatalError()
                                           }
                                           self.sheetStack.pop()
                    
                }label: {
                    
                    Text("Enable Location")
                        .bold()
                    
                }.buttonStyle(BlockButtonStyle())
            }
        }
    }

}

