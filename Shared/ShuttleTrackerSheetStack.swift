//
//  ShuttleTrackerSheetStack.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/13/23.
//

import OrderedCollections
import SheetStack
import SwiftUI

typealias ShuttleTrackerSheetStack = SheetStack<ShuttleTrackerSheetPresentationProvider.SheetType>

struct ShuttleTrackerSheetPresentationProvider: SheetPresentationProvider {
	
	enum SheetType: Hashable, Identifiable {
		
		#if os(macOS)
		case analyticsOnboarding
		#endif // os(macOS)
		
		case announcements
		
		case announcement(_ announcement: Announcement)
		
		#if os(iOS)
		case busSelection
		#endif // os(iOS)
		
		case info
		
		#if os(iOS)
		case mailCompose(
			subject: String = "",
			toRecipients: OrderedSet<String> = [],
			ccRecipients: OrderedSet<String> = [],
			bccRecipients: OrderedSet<String> = [],
			messageBody: String = "",
			isHTMLMessageBody: Bool = false,
			attachments: [MailComposeView.Attachment] = []
		)
		#endif // os(iOS)
		
		#if os(iOS) && !APPCLIP
		case networkOnboarding
		#endif // os(iOS) && !APPCLIP
		
		#if os(iOS) && !APPCLIP
		case permissions
		#endif // os(iOS) && !APPCLIP
		
		case privacy
		
		#if os(iOS) && !APPCLIP
		case settings
		#endif // os(iOS) && !APPCLIP
		
		#if !APPCLIP
		case whatsNew(onboarding: Bool)
		#endif // !APPCLIP
		
		var id: Self {
			get {
				return self
			}
		}
		
	}
	
	let sheetStack: SheetStack<SheetType>
	
	func content(sheetType: SheetType) -> some View {
		switch sheetType {
		#if os(macOS)
		case .analyticsOnboarding:
			AnalyticsOnboardingView()
				.frame(minWidth: 300, idealWidth: 500, minHeight: 200, idealHeight: 500)
		#endif // os(macOS)
		case .announcements:
			AnnouncementsSheet()
				.frame(idealWidth: 500, idealHeight: 500)
		case .announcement(let announcement):
			#if os(iOS)
			NavigationView {
				AnnouncementDetailView(announcement: announcement)
			}
			#elseif os(macOS) // os(iOS)
			AnnouncementDetailView(announcement: announcement)
			#endif // os(macOS)
		#if os(iOS)
		case .busSelection:
			BusSelectionSheet()
				.interactiveDismissDisabled()
		#endif // os(iOS)
		case .info:
			#if os(iOS)
			InfoSheet()
			#elseif os(macOS) // os(iOS)
			InfoView()
				.frame(minWidth: 300, idealWidth: 500, minHeight: 300, idealHeight: 500)
			#endif // os(macOS)
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
				Task {
					await self.sheetStack.pop()
				}
			}
		#endif // os(iOS)
		#if os(iOS) && !APPCLIP
		case .networkOnboarding:
			NetworkOnboardingView()
		#endif // os(iOS) && !APPCLIP
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
		}
	}
	
}
