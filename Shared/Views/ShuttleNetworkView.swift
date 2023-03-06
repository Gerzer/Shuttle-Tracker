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
    private var phoneScale: CGFloat = 1
    
    @State
    private var cloudScale: CGFloat = 0
    
    @State
    private var waveLScale: CGFloat = 0
    
    @State
    private var waveRScale: CGFloat = 0
    
    @State
    private var text1Scale: CGFloat = 0
    
    @State
    private var text2Scale: CGFloat = 0
    
    @State
    private var text3Scale: CGFloat = 0
    
    @State
    private var text4Scale: CGFloat = 0
    
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
                            .frame(width: 50 * self.busScale, height: 50)
                            .scaleEffect(self.busScale)
                            .onAppear() {
                                withAnimation(.easeIn(duration: 0.4)
                                    .delay(1)
                                ) {
                                    self.busScale = 1
                                }
                            }
                        Image(systemName: "wave.3.forward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50 * self.busScale, height: 50)
                            .scaleEffect(self.waveLScale)
                            .onAppear() {
                                withAnimation(.easeIn(duration: 0.4)
                                    .delay(2)
                                ) {
                                    self.waveLScale = 0.8
                                }
                            }
                        Image(systemName: "iphone")
                            .symbolRenderingMode(.monochrome)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .scaleEffect(self.phoneScale)
                            .onAppear() {
                                withAnimation(.easeIn(duration: 0.4)
                                    .delay(0)
                                ) {
                                    self.phoneScale = 1
                                }
                            }
                        Image(systemName: "wave.3.forward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50 * self.cloudScale, height: 50)
                            .scaleEffect(self.waveRScale)
                            .onAppear() {
                                withAnimation(.easeIn(duration: 0.4)
                                    .delay(6)
                                ) {
                                    self.waveRScale = 0.8
                                }
                            }
                        Image(systemName: "cloud")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70 * self.cloudScale, height: 40)
                            .scaleEffect(self.cloudScale)
                            .onAppear() {
                                //Aidan wrote this
                                //we both think this is bad code but it seems to
                                //be the only way to get the intended effect
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation(.easeIn(duration: 0.4)) {
                                        self.cloudScale = 1
                                    }
                                }
                            }
                    }
                    .padding()
                    .background(
                        .tertiary,
                        in: RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        )
                    )
                    Text("Text 1 Sample")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .scaleEffect(self.text1Scale)
                    Text("Text 2 Sample")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .scaleEffect(self.text2Scale)
                    Text("Text 3 Sample")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .scaleEffect(self.text3Scale)
                        .onAppear() {
                            withAnimation(.easeIn(duration: 1)
                                .delay(2)
                            ) {
                                self.text3Scale = 1
                            }
                        }
                }
                .padding(.top)
                .padding(.bottom)
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
