//
//  PrimaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

import SwiftUI
import StoreKit
import CoreLocation
import CoreLocationUI


extension Double {
var removeZero:String {
let nf = NumberFormatter()
nf.minimumFractionDigits = 1
nf.maximumFractionDigits = 2
    return nf.string(from: self as NSNumber)!
}
}

func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
//takes in 2 CLLocations, and computes the bearing between those 2 points


func compute_direction (point1 : CLLocation, point2 : CLLocation) -> String {
    
    let compassPoints = ["arrow.up", "arrow.up.right", "arrow.right", "arrow.down.right", "arrow.down", "arrow.down.backward", "arrow.left", "arrow.up.left", "arrow.up"]
    
    let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
    let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)
    
    let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
    let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)
    
    let dLon = lon2 - lon1
    
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    var radiansBearing = atan2(y, x)
    
    radiansBearing = (radiansBearing + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi)
    
    let degreesBearing = radiansToDegrees(radians: radiansBearing)
    let index = Int((degreesBearing / 45.0) + 0.5) % compassPoints.count
    
    return compassPoints[index]
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

    
	@EnvironmentObject  var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack

    let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)

	@AppStorage("MaximumStopDistance") private var maximumStopDistance = 50
    
    let conversionConstant = 0.000621371
    
    
    
    

	
	var body: some View {

		HStack {
			Spacer()
			if #available(iOS 15, *) {
                VStack(alignment: .leading) {
                    VStack{

                    HStack(spacing: 35){
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
                            
                            if(LocationUtilities.locationManager.location == nil){
                                
                                Button{
                                    
                                    self.sheetStack.push(.permissions)
                                    
                                    
                                }label: {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.yellow)
                                    Text("Location Error!").lineLimit(1)
                                }
                                
                                
                            }else{
                                
                                
                                let location = LocationUtilities.locationManager.location
                                var stopLocation = LocationUtilities.locationManager.location
                            
                                //we can force unwrap here as we are only here if location != nil
                                let closestStopDistance = self.mapState.stops.reduce(into: Double.greatestFiniteMagnitude) { (distance, stop) in
                                    let newDistance = stop.location.distance(from: location!)
                                    if newDistance < distance {
                                        distance = newDistance
                                        stopLocation = stop.location

                                        
                                    }
                                }
                                    
                                Text("\((closestStopDistance * conversionConstant).removeZero) mi")
                                Image(systemName: compute_direction(point1: location!, point2: stopLocation!) )
                                
                                
                                Button(action: {
                                    
                                    print("TO: \(stopLocation!.coordinate) FROM: \(LocationUtilities.locationManager.location!.coordinate)")
                                    print(compute_direction(point1: location!, point2: stopLocation!))
                                    
                                    let curr_Lattitude = LocationUtilities.locationManager.location!.coordinate.latitude
                                    let currLongittude = LocationUtilities.locationManager.location!.coordinate.longitude
                                    
                                    let destLattitude = stopLocation!.coordinate.latitude
                                    let destLongitude = stopLocation!.coordinate.longitude
                                    
                                    print(curr_Lattitude, currLongittude)
                                    
                                    print(destLattitude, destLongitude)
                                    
                                    let url = URL(string: "maps://?saddr=\(curr_Lattitude),\(currLongittude)&daddr=\(destLattitude),\(destLongitude)")
                                    
                                    
                                    if UIApplication.shared.canOpenURL(url!) {
                                          UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                                    }


                                }, label: {
                                    HStack{
                                        
                                        Image(systemName: "figure.walk")
                                        
                                    }
                                    
                                })
                                
                            }
                            
                            
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
