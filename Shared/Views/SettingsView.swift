//
//  SettingsView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SettingsView: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	@AppStorage("ColorBlindMode") private var colorBlindMode = false
    
    @AppStorage("BaseURL") private var baseURL = Self.defaultBaseURL
    
    private static let defaultBaseURL = URL(string: "https://shuttletracker.app")!

	var body: some View {
		SheetPresentationWrapper {
			Form {
				#if os(iOS)
				Section {
					HStack {
						ZStack {
							Circle()
								.fill(.green)
							Image(systemName: self.colorBlindMode ? "scope" : "bus")
								.resizable()
								.frame(width: 15, height: 15)
								.foregroundColor(.white)
						}
							.frame(width: 30)
						Toggle("Color-Blind Mode", isOn: self.$colorBlindMode)
					}
						.frame(height: 30)
				} footer: {
					Text("Modifies bus markers so that they’re distinguishable by icon in addition to color.")
				}
				#if !APPCLIP
				Section {
					Button("View Permissions") {
						self.sheetStack.push(.permissions)
					}
				}
				#endif // !APPCLIP
				Section {
					NavigationLink("Advanced") {
						AdvancedSettingsView()
					}
				}
				Section {
					NavigationLink("About") {
						AboutView()
					}
				}
				#elseif os(macOS) // os(iOS)
				Toggle("Distinguish bus markers by icon", isOn: self.$colorBlindMode)
                if #available(macOS 12, *){
                    Section {
                        TextField("Server Base URL", value: self.$baseURL, format: .compatibilityURL)
                                .labelsHidden()
                    } header: {
                        Text("Server Base URL")
                            .bold()
                    } footer: {
                        Text("The base URL for the API server. Changing this setting could make the rest of the app stop working properly.")
                            
                    }
                }
				#endif // os(macOS)
			}
				.onChange(of: self.colorBlindMode) { (_) in
					withAnimation {
						self.viewState.toastType = .legend
						self.viewState.legendToastHeadlineText = nil
					}
				}
		}
	}
	
}

struct SettingsViewPreviews: PreviewProvider {
	
	static var previews: some View {
		SettingsView()
	}
	
}
