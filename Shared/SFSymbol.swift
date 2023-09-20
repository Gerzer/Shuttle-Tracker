//
//  SFSymbol.swift
//  Shuttle Tracker
//
//  Created by Tommy Truong on 9/14/23.
//

enum SFSymbol {
	
	case announcements
	
	case bus
	
	case close
	
	case colorBlindHighQualityLocation
	
	case colorBlindLowQualityLocation
	
	case info
	
	case onboardingNode
	
	case onboardingPhone
	
	case onboardingServer
	
	case onboardingSignal
	
	case onboardingSwipeLeft
	
	case permissionDenied
	
	case permissionGranted
	
	case permissionNotDetermined
	
	case recenter
	
	case refresh
	
	case settings
	
	case stop
	
	case user
	
	case whatsNewAnalytics
	
	case whatsNewAutomaticBoardBus
	
	case whatsNewDesign
	
	case whatsNewNetwork
	
	case whatsNewNotifications
	
	var systemName: String {
		get {
			switch self {
			case .announcements:
				"exclamationmark.bubble.fill"
			case .bus:
				"bus"
			case .close:
				"xmark.circle.fill"
			case .colorBlindHighQualityLocation:
				"scope"
			case .colorBlindLowQualityLocation:
				"circle.dotted"
			case .info:
				"info.circle.fill"
			case .onboardingNode:
				"antenna.radiowaves.left.and.right.circle.fill"
			case .onboardingPhone:
				"iphone"
			case .onboardingServer:
				"cloud"
			case .onboardingSignal:
				"wave.3.forward"
			case .onboardingSwipeLeft:
				"chevron.compact.left"
			case .permissionDenied:
				"gear.badge.xmark"
			case .permissionGranted:
				"gear.badge.checkmark"
			case .permissionNotDetermined:
				"gear.badge.questionmark"
			case .recenter:
				"location.fill.viewfinder"
			case .refresh:
				"arrow.clockwise"
			case .settings:
				"gearshape.fill"
			case .stop:
				"circle.fill"
			case .user:
				"person.crop.circle"
			case .whatsNewAnalytics:
				"stethoscope"
			case .whatsNewAutomaticBoardBus:
				"location.square"
			case .whatsNewDesign:
				"star.square"
			case .whatsNewNetwork:
				"point.3.filled.connected.trianglepath.dotted"
			case .whatsNewNotifications:
				"bell.badge"
			}
		}
	}
	
}
