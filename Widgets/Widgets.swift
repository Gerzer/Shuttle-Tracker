//
//  Widgets.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/17/22.
//

import SwiftUI

@main struct Widgets: WidgetBundle {
	
	var body: some Widget {
		if #available(iOS 16.1, *) {
			BoardBusLiveActivity()
		}
	}
	
}
