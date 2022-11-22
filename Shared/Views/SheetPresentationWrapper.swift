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
				case .welcome:
					#if os(iOS) && !APPCLIP
					WelcomeSheet()
						.interactiveDismissDisabled()
					#endif // os(iOS) && !APPCLIP
				case .settings:
					#if os(iOS) && !APPCLIP
					SettingsSheet()
					#endif // os(iOS) && !APPCLIP
				case .info:
					#if os(iOS) && !APPCLIP
					InfoSheet()
					#endif // os(iOS) && !APPCLIP
				case .busSelection:
					#if os(iOS)
					BusSelectionSheet()
						.interactiveDismissDisabled()
					#endif // os(iOS)
				case .permissions:
					#if os(iOS) && !APPCLIP
					PermissionsSheet()
						.interactiveDismissDisabled()
					#endif // os(iOS) && !APPCLIP
				case .privacy:
					PrivacySheet()
				case .announcements:
					AnnouncementsSheet()
						.frame(idealWidth: 500, idealHeight: 500)
				case .whatsNew:
					#if !APPCLIP
					WhatsNewSheet()
						.frame(idealWidth: 500, idealHeight: 500)
					#endif // !APPCLIP
				case .plus(let featureText):
					#if os(iOS)
					PlusSheet(featureText: featureText)
						.interactiveDismissDisabled()
					#endif // os(iOS)
				}
			}
	}
	
	init(@ViewBuilder _ content: () -> Content) {
		self.content = content()
	}
	
}
