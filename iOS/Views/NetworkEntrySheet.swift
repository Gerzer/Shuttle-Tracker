//
//  PermissionsSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

struct NetworkEntrySheet: View {
    
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus?
    
    @State private var locationScale: CGFloat = 0
    
    @State private var notificationScale: CGFloat = 0
    
    @EnvironmentObject private var sheetStack: SheetStack
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        SheetPresentationWrapper {
            NavigationView {
               

                VStack(alignment: .leading) {
                    HStack {
                        Text("Enroll in the Shuttle Tracker Network!")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        }
                    

                        .padding(.bottom)
                    if #available(iOS 15, *) {
                        VStack(alignment: .leading) {
                            Group {
                              
                                                HStack(){
                                                              Image(systemName: "bus")
                                                                  .resizable()
                                                                  .scaledToFit()
                                                                  .frame(width: 50, height: 50)
                                                                  .foregroundColor(.accentColor)

                                                                
                                                              Text("Get live location data of busses 24/7!")
                                                          }
                                HStack {
                                                             Image(systemName: "figure.walk.circle")
                                                                 .resizable()
                                                                 .scaledToFit()
                                                                 .frame(width: 50, height: 50)
                                                                 .foregroundColor(.accentColor)

                                                             Text("Automaticlly board busses in close proximity!")
                                }
                                HStack {
                                                            Image(systemName: "network")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 50, height: 50)
                                                                .foregroundColor(.accentColor)
                                                            Text("More accurate route ETA's!")
                                                        }
                                
                                Spacer()
                                HStack{
                                    Text("Interested in the features listed above? Enroll in the shuttle tracker network today!")
                                    
                                }
                                
                                Spacer()
                            }
                                .scaleEffect(self.locationScale)
                                .onAppear {
                                    withAnimation(.easeIn(duration: 0.5)) {
                                        self.locationScale = 1.3
                                    }
                                    withAnimation(.easeOut(duration: 0.2).delay(0.5)) {
                                        self.locationScale = 1
                                    }
                                }
                    
                        }
                            .symbolRenderingMode(.multicolor)
                            .task {
                                self.notificationAuthorizationStatus = await UNUserNotificationCenter
                                    .current()
                                    .notificationSettings()
                                    .authorizationStatus
                            }
                    }
                    Spacer()
                    Button {
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
                                    print("[Network_entry body] Full-accuracy location authorization request error: \(error.localizedDescription)")
                                }
                            }
                        @unknown default:
                            fatalError()
                        }
                        self.sheetStack.pop()
                    } label: {
                        Text("Join Now!")
                            .bold()
                    }
                        .buttonStyle(BlockButtonStyle())
                }
                    .padding()
                    .toolbar {
                        ToolbarItem {
                            CloseButton()
                        }
                    }
            }
        }
    }
    
}

