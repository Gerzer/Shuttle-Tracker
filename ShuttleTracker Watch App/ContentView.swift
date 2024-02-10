//
//  ContentView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/3/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var stack = [Int]()
    
    @EnvironmentObject
    private var mapState: MapState
    
    @Binding
    private var mapCameraPosition: MapCameraPositionWrapper
    
    var body: some View {
        NavigationStack(path: $stack) {
            MapContainer(position: self.$mapCameraPosition)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(value: 1) {
                            Text("Info")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: 2) {
                            Text("Schedule")
                        }
                    }
                }
                .task {
                    await self.mapState.refreshAll()
                }
                .navigationDestination(for: Int.self) { value in
                    if value == 1 {
                        InfoView()
                    }
                    else if value == 2 {
                        ScheduleView()
                    }
                    else {
                        Text("Nothing to see here...")
                    }
            }
        }
    }
    init(mapCameraPosition: Binding<MapCameraPositionWrapper>) {
        self._mapCameraPosition = mapCameraPosition
    }
}

#Preview {
    ContentView(mapCameraPosition: .constant(MapCameraPositionWrapper(MapConstants.defaultCameraPosition)))
}
