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
    private var deviceScale: CGFloat = 0
    
    @State
    private var phoneScale: CGFloat = 1
    
    @State
    private var cloudScale: CGFloat = 0
    
    @State
    private var waveLScale: CGFloat = 0
    
    @State
    private var waveRScale: CGFloat = 0
    
    @State
    private var textValue: String = ""
    
    var body: some View {
        VStack {
            
            ScrollView {
                VStack (){
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
                                    .delay(5)
                                ) {
                                    self.busScale = 1
                                }
                            }
                            .overlay(
                                ZStack {
                                    Circle()
                                        .stroke(.gray, lineWidth: 4)
                                        .frame(width: self.deviceScale*21, height: 20)
                                    Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                                        .resizable()
                                        .frame(width: self.deviceScale*20, height: 20)
                                        .scaleEffect(self.deviceScale)
                                        .symbolRenderingMode(.monochrome)
                                        .font(.largeTitle)
                                        .foregroundColor(.black)
                                        .background(.gray, in: Circle())
                                }
                                ,alignment: .topTrailing)
                        Image(systemName: "wave.3.forward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50 * self.busScale, height: 50)
                            .scaleEffect(self.waveLScale)
                            .onAppear() {
                                withAnimation(.easeIn(duration: 0.4)
                                    .delay(15)
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
                                    .delay(25)
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
                                DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                                    withAnimation(.easeIn(duration: 0.4)) {
                                        self.cloudScale = 1
                                    }
                                }
                            }
                    }
                    .padding()
                    .background(
                        .gray,
                        in: RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        )
                    )
                    Text(self.textValue)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .onAppear() {
                            withAnimation(.easeIn(duration: 0.4)
                                .delay(0)
                            ) {
                                self.textValue = "Welcome to the Shuttle Tracker Network!"
                            }
                            withAnimation(.easeIn(duration: 0.4)
                                .delay(5)
                            ) {
                                self.textValue = "In previous iterations of Shuttle Tracker, busses weren't tracked automatically, but by users like you using the app when on a bus, using your phones location."
                            }
                            withAnimation(.easeIn(duration: 0.4)
                                .delay(10)
                            ) {
                                self.deviceScale = 1
                                self.textValue = "Now, however, the busses have been equiped with devices to communitcate to your phone automatically."
                            }
                            withAnimation(.easeIn(duration: 0.4)
                                .delay(15)
                            ) {
                                self.textValue = "When you get near a bus, the device on the bus will detect your phone and send a message to it, telling your phone that it is close to a bus"
                            }
                            withAnimation(.easeIn(duration: 0.4)
                                .delay(20)
                            ) {
                                self.textValue = "When your phone recives this signal, it will send its location to the Shuttle Tracker Network, automaitcally."
                            }
                            withAnimation(.easeIn(duration: 0.4)
                                .delay(25)
                            ) {
                                self.textValue = "With this update, busses can be tracked easily and automatically whenever a student gets on a bus and has the Shuttle Tracker app on their phone! To make sure your phone can provide bus location data to the network, make sure to turn on \"Always allow location\" and \"Allow percison location\" on your phone "
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
