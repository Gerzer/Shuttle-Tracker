//
//  MailComposeView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 12/2/22.
//

import MessageUI
import OrderedCollections
import SwiftUI
import UniformTypeIdentifiers

struct MailComposeView: UIViewControllerRepresentable {
	
	struct Attachment: Equatable, Hashable {
		
		let data: Data
		
		let type: UTType
		
		let filename: String
		
	}
	
	static var canSendMail: Bool {
		get {
			return MFMailComposeViewController.canSendMail()
		}
	}
	
	let subject: String
	
	let toRecipients: OrderedSet<String>
	
	let ccRecipients: OrderedSet<String>
	
	#if !targetEnvironment(macCatalyst)
	// Setting BCC recipients isn’t supported in Mac Catalyst
	let bccRecipients: OrderedSet<String>
	#endif // !targetEnvironment(macCatalyst)
	
	let messageBody: String
	
	let isHTMLMessageBody: Bool
	
	let attachments: [Attachment]
	
	let dismissalHandler: (((any Error)?) -> Void)?
	
	init(
		subject: String = "",
		toRecipients: OrderedSet<String> = [],
		ccRecipients: OrderedSet<String> = [],
		bccRecipients: OrderedSet<String> = [],
		messageBody: String = "",
		isHTMLMessageBody: Bool = false,
		attachments: [Attachment] = [],
		dismissalHandler: (((any Error)?) -> Void)? = nil
	) {
		self.subject = subject
		self.toRecipients = toRecipients
		self.ccRecipients = ccRecipients
		self.bccRecipients = bccRecipients
		self.messageBody = messageBody
		self.isHTMLMessageBody = isHTMLMessageBody
		self.attachments = attachments
		self.dismissalHandler = dismissalHandler
	}
	
	func makeUIViewController(context: Context) -> MFMailComposeViewController {
		let uiViewController = MFMailComposeViewController()
		uiViewController.setSubject(subject)
		uiViewController.setToRecipients(Array(self.toRecipients))
		uiViewController.setCcRecipients(Array(self.ccRecipients))
		#if !targetEnvironment(macCatalyst)
		// Setting BCC recipients isn’t supported in Mac Catalyst
		uiViewController.setBccRecipients(Array(self.bccRecipients))
		#endif // !targetEnvironment(macCatalyst)
		uiViewController.setMessageBody(self.messageBody, isHTML: self.isHTMLMessageBody)
		for attachment in self.attachments {
			guard let mimeType = attachment.type.preferredMIMEType else {
				Logging.withLogger(for: .mailCompose, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Can’t add attachment without a MIME type: \(attachment.type, privacy: .public)")
				}
				continue
			}
			uiViewController.addAttachmentData(attachment.data, mimeType: mimeType, fileName: attachment.filename)
		}
		return uiViewController
	}
	
	func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
		uiViewController.mailComposeDelegate = context.coordinator
	}
	
	func makeCoordinator() -> MailComposeViewDelegate {
		return MailComposeViewDelegate(dismissalHandler: self.dismissalHandler)
	}
	
}
