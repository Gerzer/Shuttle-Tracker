//
//  RecenterButton.swift
//  Shuttle Tracker
//
//  Created by Scott Wofford on 2/18/22.
//

import SwiftUI
import MapKit


struct RecenterButton: View {
    
    @EnvironmentObject private var mapState: MapState
    @EnvironmentObject private var viewState: ViewState
    
    var body: some View {
        if #available(iOS 15, *) {
            Button {
                self.mapState.mapView?.setVisibleMapRect(MapUtilities.mapRect, animated: true)
            } label: {
                Group {
                    Image(systemName: "location.fill.viewfinder")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .opacity(0.5)
                        .frame(width: 20)
                }
                    .frame(width: 45, height: 45)

            }
                .tint(.primary)
        }
    }
    
}
