//
//  SheetPresentationWrapper.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/3/22.
//

import SwiftUI

struct SheetPresentationWrapper<Content>: View where Content: View {
	
	@State private var sheetType: SheetStack.SheetType?
	
	@State private var handle = SheetStack.shared.register()
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	private let content: Content
	
	var body: some View {
		self.content
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
					if #available(iOS 15, *) {
						WelcomeSheet()
							.interactiveDismissDisabled()
					} else {
						WelcomeSheet()
					}
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
					if #available(iOS 15, *) {
						BusSelectionSheet()
							.interactiveDismissDisabled()
					} else {
						BusSelectionSheet()
					}
					#endif // os(iOS)
				case .permissions:
					#if os(iOS) && !APPCLIP
					if #available(iOS 15, *) {
						PermissionsSheet()
							.interactiveDismissDisabled()
					} else {
						PermissionsSheet()
					}
					#endif // os(iOS) && !APPCLIP
				case .privacy:
					PrivacySheet()
				case .announcements:
					if #available(iOS 15, macOS 12, *) {
						AnnouncementsSheet()
							.frame(idealWidth: 500, idealHeight: 500)
					}
				case .whatsNew:
					#if !APPCLIP
					WhatsNewSheet()
						.frame(idealWidth: 500, idealHeight: 500)
					#endif // !APPCLIP
				case .plus(featureText: let featureText):
					#if os(iOS)
					if #available(iOS 15, *) {
						PlusSheet(featureText: featureText)
							.interactiveDismissDisabled()
					}
					#endif // os(iOS)
				}
			}
	}
	
	init(@ViewBuilder _ content: () -> Content) {
		self.content = content()
	}
	
}

struct SheetPresentationWrapperPreviews: PreviewProvider {
	
	static var previews: some View {
		SheetPresentationWrapper { 
			EmptyView()
		}
			.environmentObject(SheetStack.shared)
	}
	
}
