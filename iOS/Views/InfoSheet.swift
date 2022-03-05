//
//  InfoSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 3/4/22.
//

import SwiftUI

struct InfoSheet: View {
	
	var body: some View {
		NavigationView {
			InfoView()
		}
	}
	
}

struct InfoSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		InfoSheet()
	}
	
}
