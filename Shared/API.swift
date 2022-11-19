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
	
	case readVersion
	
	case readAnnouncements
	
	case readBuses
	
	case readAllBuses
	
	case readBus(id: Int)
	
	case updateBus(id: Int, location: Bus.Location)
	
	case boardBus(id: Int)
	
	case leaveBus(id: Int)
	
	case readRoutes
	
	case readStops
	
	case schedule
	
	case uploadLog(log: Logging.Log)
	
	static let provider = MoyaProvider<API>()
	
	static let lastVersion = 3
	
	@MainActor
	var baseURL: URL {
		get {
			return AppStorageManager.shared.baseURL
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
			case .uploadLog:
				return "/logs"
			}
		}
	}
	
	var method: HTTPMethod {
		get {
			switch self {
			case .readVersion, .readAnnouncements, .readBuses, .readAllBuses, .readBus, .readRoutes, .readStops, .schedule:
				return .get
			case .uploadLog:
				return .post
			case .updateBus:
				return .patch
			case .boardBus, .leaveBus:
				return .put
			}
		}
	}
	
	var task: HTTPTask {
		get {
			let encoder = JSONEncoder(dateEncodingStrategy: .iso8601)
			switch self {
			case .readVersion, .readAnnouncements, .readBuses, .readAllBuses, .boardBus, .leaveBus, .readRoutes, .readStops, .schedule:
				return .requestPlain
			case .readBus(let id):
				let parameters = [
					"busid": id
				]
				return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
			case .updateBus(_, let location):
				return .requestCustomJSONEncodable(location, encoder: encoder)
			case .uploadLog(let log):
				return .requestCustomJSONEncodable(log, encoder: encoder)
			}
		}
	}
	
	var headers: [String: String]? {
		get {
			return [:]
		}
	}
	
	@discardableResult
	func perform() async throws -> Data {
		// TODO: Throw error when response status code isn’t “200 OK”
		let request = try API.provider.endpoint(self).urlRequest()
		let (data, _) = try await URLSession.shared.data(for: request)
		return data
	}
	
	func perform<ResponseType>(
		decodingJSONWith decoder: JSONDecoder = JSONDecoder(dateDecodingStrategy: .iso8601),
		as _: ResponseType.Type
	) async throws -> ResponseType where ResponseType: Decodable {
		let data = try await self.perform()
		return try decoder.decode(ResponseType.self, from: data)
	}
	
}
