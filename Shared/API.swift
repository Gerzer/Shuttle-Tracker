//
//  API.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/2/20.
//

import Foundation
import Moya

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

typealias HTTPMethod = Moya.Method

typealias HTTPTask = Moya.Task

protocol HTTPStatusCode: CaseIterable, RawRepresentable where RawValue == Int { }

enum HTTPStatusCodes {
	
	enum Information: Int, HTTPStatusCode {
		case `continue`						= 100
		case switching						= 101
		case processing						= 102
		case earlyHints						= 103
	}
	
	enum Success: Int, HTTPStatusCode {
		case ok								= 200
		case created						= 201
		case accepted						= 202
		case nonauthoritativeInformation	= 203
		case noContent						= 204
		case resetContent					= 205
		case partialContent					= 206
		case multiStatus					= 207
		case alreadyReported				= 208
		case imUsed							= 226
	}
	
	enum Redirection: Int, HTTPStatusCode {
		case multipleChoices				= 300
		case movedPermanently				= 301
		case found							= 302
		case seeOther						= 303
		case notModified					= 304
		case useProxy						= 305
		case temporaryRedirect				= 307
		case permanentRedirect				= 308
		
	}
	
	enum ClientError: Int, Error, HTTPStatusCode {
		case badRequest						= 400
		case unauthorized					= 401
		case paymentRequired				= 402
		case forbidden						= 403
		case notFound						= 404
		case methodNotAllowed				= 405
		case notAcceptable					= 406
		case proxyAuthentication			= 407
		case requestTimeout					= 408
		case conflict						= 409
		case gone							= 410
		case lengthRequired					= 411
		case preconditionFailed				= 412
		case payloadTooLarge				= 413
		case uriTooLong						= 414
		case unsupportedMediaType			= 415
		case rangeNotSatisfiable			= 416
		case expectationFailed				= 417
		case imATeapot						= 418
		case misdirectedRequest				= 421
		case unprocessableEntity			= 422
		case locked							= 423
		case failedDependency				= 424
		case tooEarly						= 425
		case upgradeRequired				= 426
		case preconditionRequired			= 428
		case tooManyRequests				= 429
		case requestHeaderFieldsTooLarge	= 431
		case unavailableForLegalReasons		= 451
	}
	
	enum ServerError: Int, Error, HTTPStatusCode {
		case internalServerError			= 500
		case notImplemented					= 501
		case badGateway						= 502
		case serviceUnavailable				= 503
		case gatewayTimeout					= 504
		case httpVersionNotSupported		= 505
		case variantAlsoNegotiable			= 506
		case insufficientStorage			= 507
		case loopDetected					= 508
		case notExtended					= 510
		case networkAuthenticationRequired	= 511
	}
	
	static let informationStatusCodes: [any HTTPStatusCode] = Information.allCases
	
	static let successStatusCodes: [any HTTPStatusCode] = Success.allCases
	
	static let errorStatusCodes: [any HTTPStatusCode] = ClientError.allCases + ServerError.allCases
	
	static let webdavStatusCodes: [any HTTPStatusCode] = [
		Information.processing,
		Success.multiStatus,
		Success.alreadyReported,
		ClientError.unprocessableEntity,
		ClientError.locked,
		ClientError.failedDependency,
		ServerError.insufficientStorage,
		ServerError.loopDetected
	]
	
	static let experimentalStatusCodes: [any HTTPStatusCode] = [
		ClientError.paymentRequired,
		ClientError.tooEarly
	]
	
}

//struct HTTPError: Error, RawRepresentable {
//	
//	
//	
//	static let errorStatusCodes: [any HTTPStatusCode] = ClientErrorStatusCode.allCases + ServerErrorStatusCode.allCases
//	
//	let rawValue: Int
//	
//	init?(rawValue: Int) {
//		let isErrorStatusCode = Self.errorStatusCodes
//			.map { (statusCode) in
//				return statusCode.rawValue
//			}
//			.contains(rawValue)
//		guard isErrorStatusCode else {
//			return nil
//		}
//		self.rawValue = rawValue
//	}
//	
//}
