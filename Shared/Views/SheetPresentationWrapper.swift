//
//  SheetPresentationWrapper.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/3/22.
//

import SwiftUI

struct SheetPresentationWrapper<Content>: View where Content: View {
	
	private let content: Content
	
	@State
	private var sheetType: SheetStack.SheetType?
	
	@State
	private var handle: SheetStack.Handle!
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	var body: some View {
		self.content
			.onAppear {
				self.handle = self.sheetStack.register()
			}
			.onReceive(self.sheetStack.publisher) { (sheets) in
				if sheets.count > self.handle.observedIndex {
					self.sheetType = sheets[self.handle.observedIndex]
				} else {
					self.sheetType = nil
				}
			}
			.onChange(of: self.sheetType) { (sheetType) in
				if self.sheetStack.count == self.handle.observedIndex {
					if let sheetType = sheetType {
						self.sheetStack.push(sheetType)
					}
				} else if self.sheetStack.count > self.handle.observedIndex {
					guard sheetType == nil else {
						return
					}
					while self.sheetStack.count - self.handle.observedIndex > 1 {
						self.sheetStack.pop()
					}
				}
			}
			.sheet(item: self.$sheetType) {
				if self.sheetStack.count > self.handle.observedIndex {
					self.sheetStack.pop()
				}
			} content: { (sheetType) in
				switch sheetType {
				#if os(macOS)
				case .analyticsOnboarding:
					AnalyticsOnboardingView()
						.frame(minWidth: 300, idealWidth: 500, minHeight: 200, idealHeight: 500)
				#endif // os(macOS)
				case .announcements:
					AnnouncementsSheet()
						.frame(idealWidth: 500, idealHeight: 500)
				#if os(iOS)
				case .busSelection:
					BusSelectionSheet()
						.interactiveDismissDisabled()
				#endif // os(iOS)
				#if os(iOS)
				case .info:
					InfoSheet()
				#endif // os(iOS)
				#if os(iOS)
				case .mailCompose(
					let subject,
					let toRecipients,
					let ccRecipients,
					let bccRecipients,
					let messageBody,
					let isHTMLMessageBody,
					let attachments
				):
					MailComposeView(
						subject: subject,
						toRecipients: toRecipients,
						ccRecipients: ccRecipients,
						bccRecipients: bccRecipients,
						messageBody: messageBody,
						isHTMLMessageBody: isHTMLMessageBody,
						attachments: attachments
					) { (_) in 
						self.sheetStack.pop()
					}
				#endif // os(iOS)
				#if os(iOS) && !APPCLIP
				case .permissions:
					PermissionsSheet()
						.interactiveDismissDisabled()
				#endif // os(iOS) && !APPCLIP
				case .privacy:
					#if os(iOS)
					PrivacySheet()
					#elseif os(macOS) // os(iOS)
					// Don’t use a navigation view on macOS
					PrivacyView()
						.frame(idealWidth: 500, idealHeight: 500)
					#endif // os(macOS)
				#if os(iOS) && !APPCLIP
				case .settings:
					SettingsSheet()
				#endif // os(iOS) && !APPCLIP
				#if !APPCLIP
				case .whatsNew(let onboarding):
					#if os(iOS)
					WhatsNewSheet(onboarding: onboarding)
						.interactiveDismissDisabled()
					#elseif os(macOS) // os(iOS)
					// Don’t use a navigation view on macOS
					WhatsNewView(onboarding: onboarding)
						.frame(idealWidth: 500, idealHeight: 500)
					#endif // os(macOS)
				#endif // !APPCLIP
                #if os(iOS) && !APPCLIP
                case .network:
                    ShuttleNetworkView()
                #endif // os(iOS) && !APPCLIP
				}
			}
	}
	
	init(@ViewBuilder _ content: () -> Content) {
		self.content = content()
	}
	
}
