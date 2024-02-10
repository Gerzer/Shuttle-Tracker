//
//  MapView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/9/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @Binding
    private var position: MapCameraPositionWrapper
    
    var body: some View {
        Map(position: self.$position.mapCameraPosition)
    }
    
    init(position: Binding<MapCameraPositionWrapper>) {
        self._position = position
    }
}

@available(iOS 17, macOS 14, *)
#Preview {
    MapView(position: .constant(MapCameraPositionWrapper(MapConstants.defaultCameraPosition)))
}
