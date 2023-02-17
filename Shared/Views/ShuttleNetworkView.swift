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
    
    @State
    private var busScale: CGFloat = 0
    
    @State
    private var phoneScale: CGFloat = 0
    
    @State
    private var cloudScale: CGFloat = 0
    
    @State
    private var stackScale: CGFloat = 0
    
    var body: some View {
        VStack {
            
            ScrollView {
                VStack {
                    Text("Shuttle Tracker Network")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    HStack {
                        Image(systemName: "bus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .scaleEffect(self.busScale)
                            .onAppear() {
                                withAnimation(.easeIn(duration: 0.7)) {
                                    self.busScale = 1.2
                                }
                                withAnimation(.easeOut(duration: 0.3)
                                    .delay(1.5)
                                    .repeatForever()
                                    .delay(0.3))
                                {
                                    self.busScale = 1
                                }
                            }
                        Image(systemName: "wave.3.forward")
                            .resizable()
                            .scaledToFit()
                            .font(Font.title.weight(.semibold))
                            .frame(width: 50, height: 50)
                        Image(systemName: "iphone")
                            .symbolRenderingMode(.monochrome)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .scaleEffect(self.phoneScale)
                            .onAppear() {
                                withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                                    self.phoneScale = 1.2
                                }
                                withAnimation(.easeOut(duration: 0.3)
                                    .delay(1.5)
                                    .repeatForever()
                                    .delay(0.6))
                                {
                                    self.phoneScale = 1
                                }
                            }
                        Image(systemName: "wave.3.forward")
                            .resizable()
                            .scaledToFit()
                            .font(Font.title.weight(.semibold))
                            .frame(width: 50, height: 50)
                        Image(systemName: "cloud")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .scaleEffect(self.cloudScale)
                            .onAppear() {
                                withAnimation(.easeIn(duration: 0.5).delay(0.6)) {
                                    self.cloudScale = 1.2
                                }
                                withAnimation(.easeOut(duration: 0.3)
                                    .delay(1.5)
                                    .repeatForever()
                                    .delay(0.9))
                                {
                                    self.cloudScale = 1
                                }
                            }
                    }
                    .scaleEffect(self.stackScale)
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
