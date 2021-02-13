//
//  API.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 10/2/20.
//

import Foundation
import Moya

typealias HTTPMethod = Moya.Method

enum API {
	
	case readBuses
	case readBus(_ id: Int)
	case updateBus(_ id: Int, location: Bus.Location)
	case boardBus(_ id: Int)
	case leaveBus(_ id: Int)
	
	static let provider = MoyaProvider<API>()
	
}

extension API: TargetType {
	
	var baseURL: URL {
		get {
			return URL(string: "https://shuttle.gerzer.software")!
		}
	}
	var path: String {
		get {
			switch self {
			case .readBuses:
				return "/buses"
			case .readBus(let id), .updateBus(let id, _):
				return "/buses/\(id)"
			case .boardBus(let id):
				return "/buses/\(id)/board"
			case .leaveBus(let id):
				return "/buses/\(id)/leave"
			}
		}
	}
	public var method: HTTPMethod {
		get {
			switch self {
			case .readBuses, .readBus:
				return .get
			case .updateBus:
				return .patch
			case .boardBus, .leaveBus:
				return .put
			}
		}
	}
	var task: Task {
		get {
			switch self {
			case .readBuses, .boardBus, .leaveBus:
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
