//
//  Toast.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/8/21.
//

import SwiftUI

struct Toast<StringType, Item, Content>: View where StringType: StringProtocol, Item: Equatable, Content: View {
	
	private var headlineString: StringType
	
	@Binding
	private var item: Item?
	
	private var onDismiss: (() -> Void)?
	
	private var content: (Item) -> Content
	
	@EnvironmentObject
	private var viewState: ViewState
	
	var body: some View {
		if let item = self.item {
			VStack(alignment: .leading) {
				HStack {
					Text(self.headlineString)
						.font(.headline)
						.accessibilityShowsLargeContentViewer()
					Spacer()
					#if os(iOS)
					Button {
						withAnimation {
							self.item = nil
						}
					} label: {
                        Image(systemName: SFSymbols.closeXMark.rawValue)
							.resizable()
							.frame(width: ViewConstants.toastCloseButtonDimension, height: ViewConstants.toastCloseButtonDimension)
					}
						.tint(.primary)
					#else // os(iOS)
					Button {
						withAnimation {
							self.item = nil
						}
					} label: {
						Image(systemName: SFSymbols.closeXMark.rawValue)
							.resizable()
							.frame(width: ViewConstants.toastCloseButtonDimension, height: ViewConstants.toastCloseButtonDimension)
					}
						.buttonStyle(.plain)
					#endif
				}
				self.content(item)
			}
				.layoutPriority(0)
				.padding()
				.background(VisualEffectView.standard)
				.cornerRadius(ViewConstants.toastCornerRadius)
				.shadow(radius: 5)
				.onChange(of: self.item) { (newValue) in
					if newValue == nil {
						self.onDismiss?()
					}
				}
		}
	}
	
	init(
		_ headlineString: StringType,
		item: Binding<Item?>,
		@ViewBuilder content: @escaping (_ item: Item, _ dismiss: @escaping () -> Void) -> Content,
		onDismiss: (() -> Void)? = nil
	) {
		self.headlineString = headlineString
		self._item = item
		self.onDismiss = onDismiss
		self.content = { (unwrappedItem) in
			return content(unwrappedItem) {
				withAnimation {
					item.wrappedValue = nil
				}
			}
		}
	}
	
}
