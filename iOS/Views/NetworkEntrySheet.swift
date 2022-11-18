//
//  NetworkOptIn.swift
//  iOS
//
//  Created by John Foster on 10/7/22.
//
import SwiftUI


 
struct NetworkEntrySheet: View {
    @EnvironmentObject private var sheetStack: SheetStack
    
    @State private var schedule: Schedule?
    
    @EnvironmentObject private var viewState: ViewState
    
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus?
    
    @State private var locationScale: CGFloat = 0
    
    @State private var notificationScale: CGFloat = 0
    
    var body: some View {
        SheetPresentationWrapper{
            NavigationView{
                ScrollView{
                    VStack(alignment: .leading, spacing: 25 ){
                        Group{
                            
                            HStack {
                                Text("Enroll in the Shuttle Tracker Network!")
                                    .font(.largeTitle)
                                    .bold()
                                    .multilineTextAlignment(.center)
                            }
                            
                            
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
                            
                            
                            HStack{
                                
                                Text("Introducing the shuttle tracker network! A new way to improve your shuttle tracker experience. opting in to the network allows you acess to features like live location data 247, automatic board bus, and accurate route ETA's. enroll in the shuttle tracker network today to get the best of your shuttle tracker experience! ")
                                    .multilineTextAlignment(.center)

                            }
                            
                            
                            
                        }    .scaleEffect(self.notificationScale)
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
                .toolbar {
                    ToolbarItem {
                        CloseButton()
                    }
                }
                
                
            }
        }.onAppear {
            if #available(iOS 15, *) {
                Task {
                    self.schedule = await Schedule.download()
                }
            }
        }
    }
}

