//
//  RefreshSequence.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 12/27/22.
//

@available(iOS 16, macOS 13, *)
actor RefreshSequence: AsyncSequence, AsyncIteratorProtocol {
	
	typealias Element = RefreshType
	
	let interval: Duration
	
	private lazy var productionTask = self.newProductionTask()
	
	init(interval: Duration) {
		self.interval = interval
	}
	
	func next() async -> RefreshType? {
		do {
			try Task.checkCancellation()
		} catch let error {
			Logging.withLogger(doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Refresh sequence canceled: \(error, privacy: .public)")
			}
			return nil
		}
		do {
			self.productionTask = self.newProductionTask()
			return try await self.productionTask.value
		} catch is CancellationError {
			return .manual
		} catch let error {
			Logging.withLogger(doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Refresh sequence production task failed: \(error, privacy: .public)")
			}
			return nil
		}
	}
	
	func trigger() {
		self.productionTask.cancel()
	}
	
	private func newProductionTask() -> Task<RefreshType, any Error> {
		return Task {
			try await Task.sleep(for: self.interval)
			return .automatic
		}
	}
	
	nonisolated func makeAsyncIterator() -> RefreshSequence {
		return self
	}
	
}

enum RefreshType {
	
	case manual, automatic
	
}
