//
//  ColorName.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 8/27/22.
//

import SwiftUI

enum ColorName: String, Codable {
	
	case red, orange, yellow, green, blue, purple, pink, gray
	
	var color: Color {
		get {
			switch self {
			case .red:
				return .red
			case .orange:
				return .orange
			case .yellow:
				return .yellow
			case .green:
				return .green
			case .blue:
				return .blue
			case .purple:
				return .purple
			case .pink:
				return .pink
			case .gray:
				return .gray
			}
		}
	}
	
}
