//
//  Logging.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/17/22.
//

import OSLog
import SwiftUI

public enum Logging {
	
	enum Category: String {
		
		case `default` = "Default"
		
		case api = "API"
		
		case location = "Location"
		
		case permissions = "Permissions"
		
		case boardBus = "BoardBus"
		
	}
	
	public struct Log: Codable, Identifiable {
		
		enum ClientPlatform: Codable {
			
			case ios, macos
			
		}
		
		public fileprivate(set) var id: UUID
		
		let content: String
		
		let clientPlatform: ClientPlatform
		
		let date: Date
		
		init(content: String) {
			self.id = UUID()
			self.content = content
			#if os(macOS)
			self.clientPlatform = .macos
			#elseif os(iOS) // os(macOS)
			self.clientPlatform = .ios
			#endif // os(iOS)
			self.date = .now
		}
		
	}
	
	private static let subsystem = "com.gerzer.shuttletracker"
	
	private static var loggers: [Category: Logger] = [:]
	
	/// Provides a customized logger to a given closure and optionally uploads the current log store after invoking the closure.
	///
	/// The user-facing log-upload opt-out is honored even when `doUpload` is set to `true`.
	/// - Warning: Don’t save or pass the provided logger outside the scope of the closure.
	/// - Parameters:
	///   - category: The subsystem category to use to customize the logger.
	///   - doUpload: Whether to upload the current log store after invoking the closure.
	///   - body: The closure to which the logger is provided.
	static func withLogger(for category: Category = .default, doUpload: Bool = false, _ body: (Logger) throws -> Void) rethrows {
		let logger = self.loggers[category] ?? {
			let logger = Logger(subsystem: self.subsystem, category: category.rawValue)
			self.loggers[category] = logger
			return logger
		}()
		try body(logger)
		Task {
			let optIn = await MainActor.run {
				return AppStorageManager.shared.doUploadLogs
			}
			if doUpload && optIn {
				do {
					try await self.uploadLog()
				} catch let error {
					self.withLogger { (logger) in // Leave `doUpload` set to `false` (the default) to avoid the potential for infinite recursion
						logger.log(level: .error, "Couldn’t upload logs: \(error)")
					}
				}
			}
		}
	}
	
	/// Uploads the current log store to the API server.
	/// - Important: This method does _not_ check the user-facing opt-out.
	/// - Throws: When retrieving the current log store or performing the API request fails.
	static func uploadLog() async throws {
		let predicate = NSPredicate(format: "subsystem == %@", argumentArray: [self.subsystem])
		let content = try OSLogStore(scope: .currentProcessIdentifier)
			.getEntries(matching: predicate)
			.reduce(into: "") { (partialResult, entry) in
				partialResult += "\(entry.composedMessage)\n"
			}
		var log = Log(content: content)
		log.id = try await API.uploadLog(log: log).perform(as: UUID.self)
		let immutableLog = log
		await MainActor.run {
			AppStorageManager.shared.uploadedLogs.append(immutableLog)
		}
	}
	
}

extension Array: RawRepresentable where Element == Logging.Log {
	
	public var rawValue: String {
		get {
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
