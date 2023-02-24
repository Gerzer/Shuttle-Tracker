//
//  PrimaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

import SwiftUI
import StoreKit

extension Double {
var removeZero:String {
let nf = NumberFormatter()
nf.minimumFractionDigits = 1
nf.maximumFractionDigits = 2
    return nf.string(from: self as NSNumber)!
}
}


struct PrimaryOverlay: View {
	
	private let timer = Timer
		.publish(every: 5, on: .main, in: .common)
		.autoconnect()
	
	private var buttonText: String {
		get {
			switch self.mapState.travelState {
			case .onBus:
				return "Leave Bus"
			case .notOnBus:
				return "Board Bus"
			}
		}
	}
	
	@State private var isRefreshing = false
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack

	@AppStorage("MaximumStopDistance") private var maximumStopDistance = 50
	
	var body: some View {
		HStack {
			Spacer()
			if #available(iOS 15, *) {
                VStack(alignment: .leading) {
                    VStack{

                    HStack(spacing: 75){
                    Button {
                        switch self.mapState.travelState {
                        case .onBus:

                            self.mapState.busID = nil
                            self.mapState.locationID = nil
                            self.mapState.travelState = .notOnBus
                            self.viewState.statusText = .thanks
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                self.viewState.statusText = .mapRefresh
                                
                            }
                            LocationUtilities.locationManager.stopUpdatingLocation()
                            
                            // Remove any pending leave-bus notifications
                            UNUserNotificationCenter
                                .current()
                                .removeAllPendingNotificationRequests()
                            
                            let windowScenes = UIApplication.shared.connectedScenes
                                .filter { (scene) in
                                    return scene.activationState == .foregroundActive
                                }
                                .compactMap { (scene) in
                                    return scene as? UIWindowScene
                                }
                            if let windowScene = windowScenes.first {
                                SKStoreReviewController.requestReview(in: windowScene)
                            }
                        case .notOnBus:
                            // TODO: Rename local `location` identifier to something more descriptive
                            guard let location = LocationUtilities.locationManager.location else {
                                break
                            }
                            let closestStopDistance = self.mapState.stops.reduce(into: Double.greatestFiniteMagnitude) { (distance, stop) in
                                let newDistance = stop.location.distance(from: location)
                                if newDistance < distance {
                                    distance = newDistance
                                }
                            }
                            if closestStopDistance < Double(self.maximumStopDistance) {
                                self.mapState.locationID = UUID()
                                self.sheetStack.push(.busSelection)
                                if self.viewState.toastType == .boardBus {
                                    self.viewState.toastType = nil
                                }
                            } else {
                                self.viewState.alertType = .noNearbyStop
                            }
                        }
                    } label: {
                        Text("Board Bus")
                            .bold()
                    }
                    .buttonStyle(.borderedProminent)
                        
                        HStack{
                            
                            
                            Text("\(mapState.nearestStopDistance) mi")
                            Image(systemName: "arrow.up.left")
                            Button(action: {
                                         
                            }, label: {
                                         HStack{
                                             //call mapstate computation
                                             
                                             Image(systemName: "figure.walk")

                                         }
        
                                     })
                        }
                        
                               
                        }
                }
					HStack {
                        Text("Enroll in the shuttle tracker network today!" )
							.layoutPriority(1)
						Spacer()
						Group {
							if self.isRefreshing {
								ProgressView()
							} else {
								Button {
									if CalendarUtilities.isAprilFools {
										self.sheetStack.push(.plus(featureText: "Refreshing the map"))
									} else {
										withAnimation {
											self.isRefreshing = true
										}
										DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
											self.refreshBuses()
										}
									}
								} label: {
									Image(systemName: "arrow.clockwise")
										.resizable()
										.aspectRatio(1, contentMode: .fit)
										.symbolVariant(.circle)
										.symbolVariant(.fill)
										.symbolRenderingMode(.multicolor)
								}
							}
						}
							.frame(width: 30)
					}
				}
					.padding()
					.background(.regularMaterial)
					.mask {
						RoundedRectangle(cornerRadius: 20, style: .continuous)
					}
					.shadow(radius: 5)
			} else {
				VStack(alignment: .leading) {
					Button {
						switch self.mapState.travelState {
						case .onBus:
							self.mapState.busID = nil
							self.mapState.locationID = nil
							self.mapState.travelState = .notOnBus
							self.viewState.statusText = .thanks
							DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
								self.viewState.statusText = .mapRefresh
							}
							LocationUtilities.locationManager.stopUpdatingLocation()
							
							// Remove any pending leave-bus notifications
							UNUserNotificationCenter
								.current()
								.removeAllPendingNotificationRequests()
						case .notOnBus:
							guard let location = LocationUtilities.locationManager.location else {
								break
							}
							let closestStopDistance = self.mapState.stops.reduce(into: Double.greatestFiniteMagnitude) { (distance, stop) in
								let newDistance = stop.location.distance(from: location)
								if newDistance < distance {
									distance = newDistance
								}
							}
							if closestStopDistance < Double(self.maximumStopDistance) {
								self.mapState.locationID = UUID()
								self.sheetStack.push(.busSelection)
								if self.viewState.toastType == .boardBus {
									self.viewState.toastType = nil
								}
							} else {
								self.viewState.alertType = .noNearbyStop
							}
						}
					} label: {
						Text(self.buttonText)
							.bold()
					}
						.buttonStyle(.block)
					HStack {
						Text(self.viewState.statusText.rawValue)
							.layoutPriority(1)
						Spacer()
						Group {
							if self.isRefreshing {
								ProgressView()
							} else {
								Button {
									withAnimation {
										self.isRefreshing = true
									}
									DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
										self.refreshBuses()
									}
								} label: {
									Image(systemName: "arrow.clockwise.circle.fill")
										.resizable()
										.aspectRatio(1, contentMode: .fit)
								}
							}
						}
							.frame(width: 30)
					}
				}
					.padding()
					.background(VisualEffectView(.systemMaterial))
					.cornerRadius(20)
					.shadow(radius: 5)
			}
			Spacer()
		}
			.padding()
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses)) { (_) in
				self.refreshBuses()
			}
			.onReceive(self.timer) { (_) in
				switch self.mapState.travelState {
				case .onBus:
					guard let coordinate = LocationUtilities.locationManager.location?.coordinate else {
						LoggingUtilities.logger.log(level: .info, "User location unavailable")
						break
					}
					LocationUtilities.sendToServer(coordinate: coordinate)
				case .notOnBus:
					break
				}
				self.refreshBuses()
			}
	}
	
	func refreshBuses() {
		[Bus].download { (buses) in
			DispatchQueue.main.async {
				self.mapState.buses = buses
				withAnimation {
					self.isRefreshing = false
				}
			}
		}
		[Stop].download { (stops) in
			DispatchQueue.main.async {
				self.mapState.stops = stops
			}
		}
		[Route].download { (routes) in
			DispatchQueue.main.async {
				self.mapState.routes = routes
			}
		}
//		if let location = locationManager.location {
//			let locationMapPoint = MKMapPoint(location.coordinate)
//			let nearestStop = self.mapState.stops.min { (firstStop, secondStop) in
//				let firstStopDistance = MKMapPoint(firstStop.coordinate).distance(to: locationMapPoint)
//				let secondStopDistance = MKMapPoint(secondStop.coordinate).distance(to: locationMapPoint)
//				return firstStopDistance < secondStopDistance
//			}
//			let busPoints = self.mapState.buses.map { (bus) -> (bus: Bus, mapPoint: MKMapPoint) in
//
//			}
//			self.statusText = "The next bus is \("?") meters away from the nearest stop."
//		}
	}
	
}

struct PrimaryOverlayPreviews: PreviewProvider {
	
	static var previews: some View {
		PrimaryOverlay()
			.environmentObject(MapState.shared)
			.environmentObject(ViewState.shared)
	}
	
}
