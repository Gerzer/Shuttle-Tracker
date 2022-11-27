//
//  API.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/2/20.
//

import Foundation
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
	
	static let provider = MoyaProvider<API>()
	
	static let lastVersion = 3
	
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
	
	@discardableResult
	func perform() async throws -> Data {
		let request = try API.provider.endpoint(self).urlRequest()
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else {
			return data // TODO: Throw error instead
		}
		// TODO: Throw error if `httpResponse`’s status code indicates an HTTP error
		
		return data
	}
	
	func perform<ResponseType>(
		decodingJSONWith decoder: JSONDecoder = {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			return decoder
		}(),
		as _: ResponseType.Type
	) async throws -> ResponseType where ResponseType: Decodable {
		let data = try await self.perform()
		return try decoder.decode(ResponseType.self, from: data)
	}
	
}
