//
//  API.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/2/20.
//

import Foundation
import HTTPStatus
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
	
	case readSchedule
	
	case uploadAnalyticsEntry(analyticsEntry: Analytics.Entry)
	
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
			case .readSchedule:
				return "/schedule"
			case .uploadAnalyticsEntry:
				return "/analytics/entries"
			case .uploadLog:
				return "/logs"
			}
		}
	}
	
	var method: HTTPMethod {
		get {
			switch self {
			case .readVersion, .readAnnouncements, .readBuses, .readAllBuses, .readBus, .readRoutes, .readStops, .readSchedule:
				return .get
			case .uploadAnalyticsEntry, .uploadLog:
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
			case .readVersion, .readAnnouncements, .readBuses, .readAllBuses, .boardBus, .leaveBus, .readRoutes, .readStops, .readSchedule:
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
			case .uploadAnalyticsEntry(let analyticsEntry):
				return .requestCustomJSONEncodable(analyticsEntry, encoder: encoder)
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
		let request = try API.provider.endpoint(self).urlRequest()
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else {
			throw APIError.invalidResponse
		}
		guard let statusCode = HTTPStatusCodes.statusCode(httpResponse.statusCode) else {
			throw APIError.invalidStatusCode
		}
		if let error = statusCode as? any Error {
			throw error
		} else {
			return data
		}
	}
	
	func perform<ResponseType>(
		decodingJSONWith decoder: JSONDecoder = JSONDecoder(dateDecodingStrategy: .iso8601),
		as _: ResponseType.Type,
		onMainActor: Bool = false
	) async throws -> ResponseType where ResponseType: Sendable & Decodable {
		let data = try await self.perform()
		if onMainActor {
			return try await MainActor.run {
				return try decoder.decode(ResponseType.self, from: data)
			}
		} else {
			return try decoder.decode(ResponseType.self, from: data)
		}
	}
	
}

fileprivate enum APIError: LocalizedError {
	
	case invalidResponse
	
	case invalidStatusCode
	
	var errorDescription: String? {
		get {
			switch self {
			case .invalidResponse:
				return "The server returned an invalid response."
			case .invalidStatusCode:
				return "The server returned an invalid HTTP status code."
			}
		}
	}
	
}
