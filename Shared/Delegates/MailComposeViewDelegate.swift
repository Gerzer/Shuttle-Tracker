//
//  MailComposeViewDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 12/2/22.
//

import MessageUI

final class MailComposeViewDelegate: NSObject, MFMailComposeViewControllerDelegate {
	
	let dismissalHandler: (((any Error)?) -> Void)?
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
		Logging.withLogger(for: .mailCompose, doUpload: error != nil) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did finish with \(result.rawValue) error \(error, privacy: .public)")
			if let error {
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to send email: \(error, privacy: .public)")
			}
		}
		self.dismissalHandler?(error)
	}
	
	init(dismissalHandler: (((any Error)?) -> Void)?) {
		self.dismissalHandler = dismissalHandler
	}
	
}
