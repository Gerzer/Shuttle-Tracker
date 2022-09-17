//
//  BoardBusIntent.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/9/22.
//

import Foundation
import AppIntents

@available(iOS 16, *)
struct BoardBusIntent: AppIntent {
	
	static let title: LocalizedStringResource = "Board Bus"
	
	static let description = IntentDescription("Activates Board Bus if you’re within the maximum distance threshold of a shuttle stop.")
	
	static let parameterSummary = Summary("Board bus \(\.$busID)")
	
	@Parameter(title: "Bus ID Number") var busID: Int?
	
	enum CustomDialog {
		
		case busIDParameterPrompt
		
		case busIDParameterDisambiguationIntro(count: Int, busID: Int)
		
		case busIDParameterConfirmation(busID: Int)
		
		var asDialog: IntentDialog {
			switch self {
			case .busIDParameterPrompt:
				return IntentDialog("What’s the ID number of the bus that you’re boarding?")
			case .busIDParameterDisambiguationIntro(let count, let busID):
				return IntentDialog("There are \(count) options matching bus \(busID).")
			case .busIDParameterConfirmation(let busID):
				return IntentDialog("Just to confirm, you’re boarding bus \(busID)?")
			}
		}
	}
	
	func perform() async throws -> some IntentResult {
		guard let location = LocationUtilities.locationManager.location else {
			.result(dialog: "You haven’t given Shuttle Tracker access to your location.")
		}
		let closestStopDistance = MapState.shared.stops.reduce(into: Double.greatestFiniteMagnitude) { (distance, stop) in
			let newDistance = stop.location.distance(from: location)
			if newDistance < distance {
				distance = newDistance
			}
		}
		let maximumStopDistance = AppStorageManager.shared.maximumStopDistance
		if closestStopDistance < Double(maximumStopDistance) {
			self.mapState.locationID = UUID()
			// TODO: Set bus ID
			return .result()
		} else {
			return .result(dialog: "You can’t board a bus because aren’t within \(maximumStopDistance) meters of a stop.")
		}
	}
}

