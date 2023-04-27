//
//  Bus_view_sheet.swift
//  Shuttle Tracker
//
//  Created by John Foster on 4/26/23.
//

import SwiftUI

struct Bus_view_sheet: View {
    var busRoutes = ["North", "West"]
    
    var body: some View {
        VStack {
            HStack(spacing:5){
                Text("Active Routes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                CloseButton()
            }
            
            HStack {
                Button(action: {}) {
                    VStack {
                        Image(systemName: "bus.fill")
                        Text("All Routes")
                    }
                    .padding()
                    .foregroundColor(.black)
                }
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .padding()
                
                Button(action: {}) {
                    VStack {
                        Image(systemName: "map.fill")
                        Text("Map View")
                    }
                    .padding()
                    .foregroundColor(.black)
                }
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .padding()
            }
            
            List(busRoutes, id: \.self) { route in
                Text("Bus Route \(route)")
            }
        }
        .accentColor(.red)
    }
}

