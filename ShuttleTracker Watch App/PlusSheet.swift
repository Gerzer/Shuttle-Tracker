//
//  PlusSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 3/19/22.
//

import SwiftUI

struct PlusSheet: View {
	
	@State
	private var doShowAlert = false
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Shuttle Tracker+")
                        .font(.largeTitle)
                        .bold()
                        .rainbow()
                    Spacer()
                }
                .padding(.bottom)
                Text("Subscribe to Shuttle Tracker+ today to get the best Shuttle Tracker experience. It’s just $9.99 per week. That’s cheap!")
                    .padding(.bottom)
                Spacer()
                Button {
                    self.doShowAlert = true
                } label: {
                    Text("Subscribe")
                        .bold()
                }
                .buttonStyle(.automatic)
            }
            .padding([.horizontal, .bottom])
            .alert("April Fools!", isPresented: self.$doShowAlert) {
                Button("Dismiss") {
                    self.doShowAlert = false
                }
            }
        }
	}
	
}

#Preview {
	PlusSheet()
		.environmentObject(ShuttleTrackerSheetStack())
}
