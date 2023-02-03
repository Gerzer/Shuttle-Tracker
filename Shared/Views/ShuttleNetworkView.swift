//
//  ShuttleNetworkView.swift
//  Shuttle Tracker
//
//  Created by Ian Evans on 1/31/23.
//
//Will hold the code for the view that pushes users to turn on always on notifications

import StoreKit
import SwiftUI

struct ShuttleNetworkView: View {

    var body: some View {
        VStack {
            Spacer()
            ScrollView {
                VStack(alignment: .leading) {
                    Text("The Shuttle Tracker \nNetwork")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                }
            }
            Button {
                //Add button actions: will push a request to settings for always on location
            } label: {
                HStack{
                    Image(systemName: "location.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("Turn Location Servies Always On")
                        .bold()
                }
            }
                .buttonStyle(.block)
                .padding(.horizontal)
                .padding(.bottom)
            Button {
                //button will close the page
            } label: {
                Text("Later")
            }
        }
        //.padding(.bottom)
    }
    
}

struct AnnoyView_Previews: PreviewProvider {
    static var previews: some View {
        ShuttleNetworkView()
    }
}
