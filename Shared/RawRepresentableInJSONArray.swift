//
//  RawRepresentableInJSONArray.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/17/23.
//

import Foundation

// We use a dedicated protocol instead of just extending Array for all Element specializations that conform to Codable to avoid creating retroactive conformaces.

public protocol RawRepresentableInJSONArray: Codable { }

extension Array: RawRepresentable where Element: RawRepresentableInJSONArray {
	
	public var rawValue: String {
		get {
			// Serialize this array into a single JSON string
			return (try? JSONEncoder().encode(self)).flatMap { (data) in
				return String(data: data, encoding: .utf8)
			} ?? "[ ]"
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
