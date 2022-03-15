//
//  PrivacySheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/4/22.
//

import SwiftUI

struct PrivacySheet: View {
	
	var body: some View {
		NavigationView {
			PrivacyView()
		}
	}
	
}

struct PrivacySheetPreviews: PreviewProvider {
	
	static var previews: some View {
		PrivacySheet()
	}
	
}
