//
//  ShuttleNetworkView.swift
//  Shuttle Tracker
//
//  Created by Ian Evans on 1/31/23.
//
//Will hold the code for the view that pushes users to turn on always on notifications

import StoreKit
import SwiftUI
import CoreLocation

struct ShuttleNetworkView: View {
    
    @EnvironmentObject
    private var sheetStack: SheetStack
    
    @ScaledMetric
    var textScale: CGFloat = 1 //used for dynamic type sizing for logos
    
    @Environment(\.openURL)
    private var openURL
    
    var body: some View {
        VStack {
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Shuttle Tracker Network")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                    .padding(.top)
            }
            Button {
                switch (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
                case (.authorizedAlways, .fullAccuracy):
                    break
                case (.notDetermined, _):
                    CLLocationManager.default.requestWhenInUseAuthorization()
                    CLLocationManager.default.requestAlwaysAuthorization()
                default:
                    self.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
                self.sheetStack.pop()
            } label: {
                HStack{
                    Image(systemName: "location.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15 * textScale, height: 15 * textScale)
                    Text("Turn Location Servies Always On")
                        .bold()
                }
            }
                .buttonStyle(.block)
                .padding(.horizontal)
                .padding(.bottom)
            Button {
                self.sheetStack.pop()
            } label: {
                Text("Later")
            }
                .padding(.bottom)
        }
    }
}

struct AnnoyView_Previews: PreviewProvider {
    static var previews: some View {
        ShuttleNetworkView()
    }
}
