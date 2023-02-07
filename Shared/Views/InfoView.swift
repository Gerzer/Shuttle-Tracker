//
//  InfoView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/4/22.
//

import SwiftUI

struct InfoView: View {
	
	@State
	private var schedule: Schedule?
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	private var highQualityMessage: String {
		get {
			return self.appStorageManager.colorBlindMode ? "The scope icon indicates high-quality location data" : "Green buses indicate high-quality location data" // Capitalization is appropriate for the beginning of a sentence
		}
	}
	
	private var lowQualityMessage: String {
		get {
			return self.appStorageManager.colorBlindMode ? "the dotted-circle icon indicates low-quality location data" : "red buses indicate low-quality location data" // Capitalization is appropriate for the middle of a sentence
		}
	}
	
	var body: some View {
		SheetPresentationWrapper {
			ScrollView {
                VStack(spacing: 0){
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Shuttle Tracker shows you the real-time locations of the Rensselaer campus shuttles, powered by crowd-sourced location data.")
                            .padding(.vertical)
                        
                        if let schedule = self.schedule {
                            Section {
                                VStack {
                                    let days = [
                                        ("Monday", "\(schedule.content.monday.start)", "\(schedule.content.monday.end)"),
                                        ("Tuesday", "\(schedule.content.tuesday.start)", "\(schedule.content.tuesday.end)"),
                                        ("Wednesday", "\(schedule.content.wednesday.start)", "\(schedule.content.wednesday.end)"),
                                        ("Thursday", "\(schedule.content.thursday.start)", "\(schedule.content.thursday.end)"),
                                        ("Friday", "\(schedule.content.friday.start)", "\(schedule.content.friday.end)"),
                                        ("Saturday", "\(schedule.content.saturday.start)", "\(schedule.content.monday.end)"),
                                        ("Sunday", "\(schedule.content.sunday.start)", "\(schedule.content.sunday.end)"),
                                    ]
                                    
                                    ForEach(days, id: \.0) { item in
                                        HStack {
                                            Text(item.0)
                                                .bold()
                                                .padding(.leading, 5)
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 0){
                                                ZStack(alignment: .trailing){
                                                    Text(days.max(by: { $1.1.count > $0.1.count })!.1)
                                                        .foregroundColor(.clear)
                                                        .bold()
                                                    
                                                    Text(item.1).bold()
                                                }
                                                    .padding(3)
                                                    .padding(.horizontal, 3)
                                                    .background(Color(.systemGray5))
                                                    .cornerRadius(10)
                                                
                                                Text(" to ")
                                                
                                                ZStack(alignment: .trailing){
                                                    Text(days.max(by: { $1.2.count > $0.2.count })!.2)
                                                        .foregroundColor(.clear)
                                                        .bold()
                                                    
                                                    Text(item.2).bold()
                                                }
                                                    .padding(3)
                                                    .padding(.horizontal, 3)
                                                    .background(Color(.systemGray5))
                                                    .cornerRadius(10)
                                            }
                                        }
                                        .padding(3)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.bottom)
                            } header: {
                                Text("Schedule")
                                    .padding(.vertical, 5)
                                    .font(.title)
                            }
                        }
                        Section {
                            VStack {
                                Text("The map is automatically refreshed every 5 seconds.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(.green)
                                            .shadow(color: .green, radius: 3)
                                        Image(systemName: self.appStorageManager.colorBlindMode ? "scope" : "bus")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                    }
                                        .frame(width: 50)
                                    
                                    let message = self.lowQualityMessage.prefix(1).uppercased() + self.lowQualityMessage.dropFirst(1)
                                    Text(message)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(10)
                                .background(.thinMaterial)
                                .cornerRadius(10)
                                
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(self.appStorageManager.colorBlindMode ? .purple : .red)
                                            .shadow(color: self.appStorageManager.colorBlindMode ? .purple : .red, radius: 3)
                                        Image(systemName: self.appStorageManager.colorBlindMode ? "circle.dotted" : "bus")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                    }
                                        .frame(width: 50)
                                    
                                    let message = self.highQualityMessage.prefix(1).uppercased() + self.highQualityMessage.dropFirst(1)
                                    Text(message)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(10)
                                .background(.thinMaterial)
                                .cornerRadius(10)
                                
                                Text("When boarding a bus, tap “Board Bus”, and when getting off, tap “Leave Bus”. You must be within \(self.appStorageManager.maximumStopDistance) meter\(self.appStorageManager.maximumStopDistance == 1 ? "" : "s") of a stop to board a bus.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom)
                            }
                        } header: {
                            Text("Instructions")
                                .padding(.vertical, 5)
                                .font(.title)
                        }
                        Section {
                            Button("Show Privacy Information") {
                                self.sheetStack.push(.privacy)
                            }
                            .padding(.bottom)
                        }
                    }
                    .padding(.horizontal)
                    .background(.thinMaterial)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
			}
                .navigationTitle("Shuttle Tracker")
				.toolbar {
					ToolbarItem {
						CloseButton()
					}
				}
		}
			.onAppear {
				Task {
					self.schedule = await Schedule.download()
				}
			}
	}
	
}

struct InfoViewPreviews: PreviewProvider {
	
	static var previews: some View {
		InfoView()
			.environmentObject(ViewState.shared)
			.environmentObject(AppStorageManager.shared)
			.environmentObject(SheetStack())
	}
	
}
