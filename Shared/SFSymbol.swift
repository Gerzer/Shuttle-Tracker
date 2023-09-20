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
	
	case loggingAnalytics
	
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
				return "exclamationmark.bubble"
			case .bus:
				return "bus"
			case .close:
				return "xmark.circle.fill"
			case .colorBlindHighQualityLocation:
				return "scope"
			case .colorBlindLowQualityLocation:
				return "circle.dotted"
			case .info:
				return "info.circle"
			case .loggingAnalytics:
				return "text.redaction"
			case .onboardingNode:
				return "antenna.radiowaves.left.and.right.circle.fill"
			case .onboardingPhone:
				return "iphone"
			case .onboardingServer:
				return "cloud"
			case .onboardingSignal:
				return "wave.3.forward"
			case .onboardingSwipeLeft:
				return "chevron.compact.left"
			case .permissionDenied:
				return "gear.badge.xmark"
			case .permissionGranted:
				return "gear.badge.checkmark"
			case .permissionNotDetermined:
				return "gear.badge.questionmark"
			case .recenter:
				return "location.viewfinder"
			case .refresh:
				return "arrow.clockwise"
			case .settings:
				return "gearshape"
			case .stop:
				return "circle.fill"
			case .user:
				return "person.crop.circle"
			case .whatsNewAnalytics:
				return "stethoscope"
			case .whatsNewAutomaticBoardBus:
				return "location.square"
			case .whatsNewDesign:
				return "star.square"
			case .whatsNewNetwork:
				return "point.3.filled.connected.trianglepath.dotted"
			case .whatsNewNotifications:
				return "bell.badge"
			}
		}
	}
	
}
