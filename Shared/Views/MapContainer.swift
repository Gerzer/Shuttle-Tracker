//
//  MapContainer.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 8/22/23.
//

import MapKit
import SwiftUI

@available(iOS 17, macOS 14, *)
struct MapContainer: View {
	
	@State
	private var buses: [Bus] = []
	
	@State
	private var stops: [Stop] = []
	
	@State
	private var routes: [Route] = []
	
	@Binding
	private var position: MapCameraPositionWrapper
	
	@EnvironmentObject
	private var mapState: MapState
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	#if os(iOS)
	@State
	private var busID: Int?
	
	@State
	private var travelState: BoardBusManager.TravelState?
	
	@EnvironmentObject
	private var boardBusManager: BoardBusManager
	#endif // os(iOS)
	
	var body: some View {
		Map(position: self.$position.mapCameraPosition) {
			ForEach(self.buses) { (bus) in
				Marker(
					bus.title!, // MKAnnotation requires that the title property be optional, but our implementation always returns a non-nil value.
					systemImage: bus.systemImage,
					coordinate: bus.coordinate
				)
					.tint(bus.tintColor)
					.mapOverlayLevel(level: .aboveLabels)
			}
			ForEach(self.stops) { (stop) in
				Annotation(
					stop.title!, // MKAnnotation requires that the title property be optional, but our implementation always returns a non-nil value.
					coordinate: stop.coordinate
				) {
					Circle()
						.size(width: 12, height: 12)
						.fill(.white)
						.stroke(.black, lineWidth: 3)
				}
			}
			ForEach(self.routes) { (route) in
				MapPolyline(points: route.mapPoints, contourStyle: .geodesic)
					.stroke(route.mapColor, lineWidth: 5)
			}
			#if os(iOS)
			if case .some(.onBus) = self.travelState, let busID = self.busID, let coordinate = CLLocationManager.default.location?.coordinate {
				Marker("Bus \(busID)", systemImage: SFSymbol.user.systemName, coordinate: coordinate)
			} else {
				UserAnnotation()
			}
			#else // os(iOS)
			UserAnnotation()
			#endif // os(macOS)
		}
			.mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: true))
			.task {
				await self.updateAppStorageData()
				#if os(iOS)
				await self.updateBoardBusData()
				#endif // os(iOS)
			}
			.onReceive(self.mapState.objectWillChange) {
				Task {
					await self.updateAppStorageData()
				}
			}
			#if os(iOS)
			.onReceive(self.boardBusManager.objectWillChange) {
				Task {
					await self.updateBoardBusData()
				}
			}
			#endif // os(iOS)
	}
	
	init(position: Binding<MapCameraPositionWrapper>) {
		self._position = position
	}
	
	private func updateAppStorageData() async {
		self.buses = await self.mapState.buses
		self.stops = await self.mapState.stops
		self.routes = await self.mapState.routes
	}
	
	#if os(iOS)
	private func updateBoardBusData() async {
		self.busID = await self.boardBusManager.busID
		self.travelState = await self.boardBusManager.travelState
	}
	#endif // os(iOS)
	
}

@available(iOS 17, macOS 14, *)
#Preview {
	MapContainer(position: .constant(MapCameraPositionWrapper(MapConstants.defaultCameraPosition)))
		.environmentObject(MapState.shared)
		.environmentObject(AppStorageManager.shared)
		#if os(iOS)
		.environmentObject(BoardBusManager.shared)
		#endif // os(iOS)
}
