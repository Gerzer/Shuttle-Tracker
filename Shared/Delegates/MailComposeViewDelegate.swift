//
//  MailComposeViewDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 12/2/22.
//

import MessageUI
import STLogging

final class MailComposeViewControllerDelegate: NSObject, MFMailComposeViewControllerDelegate {
	
	let dismissalHandler: (((any Error)?) -> Void)?
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
		#log(system: Logging.system, category: .mailComposeViewControllerDelegate, level: .info, "Did finish with \(result.rawValue) error \(error, privacy: .public)")
		if let error {
			#log(system: Logging.system, category: .mailCompose, level: .error, doUpload: true, "Failed to send email: \(error, privacy: .public)")
		}
		self.dismissalHandler?(error)
	}
	
	init(dismissalHandler: (((any Error)?) -> Void)?) {
		self.dismissalHandler = dismissalHandler
	}
	
}
