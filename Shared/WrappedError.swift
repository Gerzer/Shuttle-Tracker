//
//  WrappedError.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/18/22.
//

import Foundation

struct WrappedError: LocalizedError {
	
	let error: (any Error)?
	
	var errorDescription: String? {
		get {
			return self.error?.localizedDescription
		}
	}
	
	init(_ error: (any Error)? = nil) {
		self.error = error
	}
	
}

extension Optional where Wrapped == WrappedError {
	
	var isNotNil: Bool {
		get {
			return self != nil
		}
		set {
			if newValue {
				if self == nil {
					self = WrappedError()
				}
			} else {
				self = nil
			}
		}
	}
	
}
