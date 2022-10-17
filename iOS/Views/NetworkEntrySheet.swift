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
    
    var body: some View {
        SheetPresentationWrapper{
            NavigationView{
                ScrollView{
                    VStack(alignment: .leading, spacing: 0 ){
                        
                    }
                }
                .navigationTitle("Shuttle Tracker 🚐")
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

