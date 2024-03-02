//
//  PlusSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 3/19/22.
//

import SwiftUI

struct PlusSheet: View {
	
	let featureText: String
	
	@State
	private var doShowAlert = false
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    #if !os(watchOS)
                    Spacer()
                    #endif
                    Text("Shuttle Tracker+")
                        .font(.largeTitle)
                        .bold()
                        .rainbow()
                    Spacer()
                }
                #if !os(watchOS)
                .padding(.top, 40)
                #endif
                .padding(.bottom)
                Text("\(self.featureText) is a Plus feature.")
                    .font(.title3)
                    .bold()
                Text("Subscribe to Shuttle Tracker+ today to get the best Shuttle Tracker experience. It’s just $9.99 per week. That’s cheap!")
                    .padding(.bottom)
                Text("Shuttle Tracker+ exclusive features:")
                    .font(.headline)
                Text("• Refreshing the map")
                Text("• Changing settings")
                Text("• Viewing app information")
                Text("• Supporting broke college students")
                Spacer()
                Button {
                    self.doShowAlert = true
                } label: {
                    Text("Subscribe")
                        .bold()
                }
#if !os(watchOS)
                .buttonStyle(.block)
#else
                .buttonStyle(.automatic)
#endif
                
            }
            .padding([.horizontal, .bottom])
            .alert("April Fools!", isPresented: self.$doShowAlert) {
                Button("Dismiss") {
                    #if !os(watchOS)
                    self.sheetStack.pop()
                    #else
                    self.doShowAlert = false
                    #endif
                }
            }
        }
	}
	
}

#Preview {
	PlusSheet(featureText: "Refreshing the map")
		.environmentObject(ShuttleTrackerSheetStack())
}
