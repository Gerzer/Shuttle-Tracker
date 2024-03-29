//
//  ContentView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/3/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject
    private var mapState: MapState
    
    @State
    private var announcements: [Announcement] = []
    
    @State
    private var didResetViewedAnnouncements = false
    
    @State 
    private var showInfoSheet = false
    
    @Binding
    private var mapCameraPosition: MapCameraPositionWrapper
    
    var body: some View {
        NavigationView {
            MapContainer(position: self.$mapCameraPosition)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            Task {
                                await self.mapState.recenter(position: self.$mapCameraPosition)
                            }
                        } label: {
                            Label("Re-Center Map", systemImage: SFSymbol.recenter.systemName)
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            self.showInfoSheet.toggle()
                        }, label: {
                            Label("Informations Tab", systemImage: SFSymbol.info.systemName)
                        })
                    }
                }
            }
            .task {
                await self.mapState.refreshAll()
            }
            .sheet(isPresented: self.$showInfoSheet, content: {
                InfoView()
            })
    }
    
    init(mapCameraPosition: Binding<MapCameraPositionWrapper>) {
        self._mapCameraPosition = mapCameraPosition
    }
}

#Preview {
    ContentView(mapCameraPosition: .constant(MapCameraPositionWrapper(MapConstants.defaultCameraPosition)))
}
