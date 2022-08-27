//
//  API.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/2/20.
//

import SwiftUI
import Moya

typealias HTTPMethod = Moya.Method

typealias HTTPTask = Moya.Task

enum API: TargetType {
	
	private struct SettingsContainer {
		
		static let shared = SettingsContainer()
		
		@AppStorage("BaseURL") private(set) var baseURL = URL(string: "https://shuttletracker.app")!
		
		private init() { }
		
	}
	
	case readVersion
	
	case readAnnouncements
	
	case readBuses
	
	case readAllBuses
	
	case readBus(_ id: Int)
	
	case updateBus(_ id: Int, location: Bus.Location)
	
	case boardBus(_ id: Int)
	
	case leaveBus(_ id: Int)
	
	case readRoutes
	
	case readStops
	
	case schedule
	
	static let provider = MoyaProvider<API>()
	
	static let lastVersion = 2
	
	var baseURL: URL {
		get {
			return SettingsContainer.shared.baseURL
		}
	}
	
	var path: String {
		get {
			switch self {
			case .readVersion:
				return "/version"
			case .readAnnouncements:
				return "/announcements"
			case .readBuses:
				return "/buses"
			case .readAllBuses:
				return "/buses/all"
			case .readBus(let id), .updateBus(let id, _):
				return "/buses/\(id)"
			case .boardBus(let id):
				return "/buses/\(id)/board"
			case .leaveBus(let id):
				return "/buses/\(id)/leave"
			case .readRoutes:
				return "/routes"
			case .readStops:
				return "/stops"
			case .schedule:
				return "/schedule"
			}
		}
	}
	
	public var method: HTTPMethod {
		get {
			switch self {
			case .readVersion, .readAnnouncements, .readBuses, .readAllBuses, .readBus, .readRoutes, .readStops, .schedule:
				return .get
			case .updateBus:
				return .patch
			case .boardBus, .leaveBus:
				return .put
			}
		}
	}
	
	var task: HTTPTask {
		get {
			switch self {
			case .readVersion, .readAnnouncements, .readBuses, .readAllBuses, .boardBus, .leaveBus, .readRoutes, .readStops, .schedule:
				return .requestPlain
			case .readBus(let id):
				let parameters = [
					"busid": id
				]
				return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
			case .updateBus(_, let location):
				let encoder = JSONEncoder()
				encoder.dateEncodingStrategy = .iso8601
				return .requestCustomJSONEncodable(location, encoder: encoder)
			}
		}
	}
	
	var headers: [String: String]? {
		get {
			return [:]
		}
	}
	
	var sampleData: Data {
		get {
			return "{}".data(using: .utf8)!
		}
	}
	
}
