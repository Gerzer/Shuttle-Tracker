//
//  BusOption.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

import SwiftUI

struct BusOption: View {
	
	private let busID: BusID
	
	@Binding
	private var selectedBusID: BusID?
	
	private let feedbackGenerator = UISelectionFeedbackGenerator()
	
	var body: some View {
		Button {
			if self.selectedBusID != self.busID {
				withAnimation {
					self.feedbackGenerator.selectionChanged()
					self.selectedBusID = self.busID
				}
			}
		} label: {
			Text("\(self.busID.rawValue)")
				.bold()
				.foregroundColor(.primary)
				.frame(maxWidth: .infinity, minHeight: 100)
				.innerShadow(
					using: RoundedRectangle(cornerRadius: 10),
					color: .primary,
					width: self.busID == self.selectedBusID ? 5 : 0
				)
				.overlay(
					RoundedRectangle(cornerRadius: 10)
						.stroke(
							self.busID == self.selectedBusID ? Color.accentColor : .primary,
							lineWidth: self.busID == self.selectedBusID ? 5 : 2
						)
				)
		}
			.onAppear {
				self.feedbackGenerator.prepare()
			}
	}
	
	init(_ busID: BusID, selection selectedBusID: Binding<BusID?>) {
		self.busID = busID
		self._selectedBusID = selectedBusID
	}
	
}

#Preview {
	BusOption(BusID(42), selection: .constant(nil))
}
