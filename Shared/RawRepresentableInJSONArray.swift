//
//  RawRepresentableInJSONArray.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/17/23.
//

import Foundation

public protocol RawRepresentableInJSONArray: Codable { }

extension Array: RawRepresentable where Element: RawRepresentableInJSONArray {
	
	public var rawValue: String {
		get {
			// Serialize this array into a single JSON string
			let data = try! JSONEncoder().encode(self)
			return String(data: data, encoding: .utf8)!
		}
	}
	
	public init?(rawValue: String) {
		guard let data = rawValue.data(using: .utf8) else {
			return nil
		}
		guard let log = try? JSONDecoder().decode(Self.self, from: data) else {
			return nil
		}
		self = log
	}
	
}
