//
//  FadeScrollView.swift
//  Shuttle Tracker
//
//  Created by Yi Chen on 12/8/23.
//

import SwiftUI

struct FadeScrollView<Content: View>: View {
	
	private let content: Content
	
	@State
	private var height: Double = .zero
	
	@Environment(\.colorScheme)
	private var colorScheme
	
	private var fadeColor: Color {
		get {
			switch self.colorScheme {
			case .dark:
				return .black
			case .light:
				return .white
			@unknown default:
				return .clear
			}
		}
	}
	
	var body: some View {
		GeometryReader { (outerGeometry) in
			ZStack {
				ScrollView {
					self.content
						.background(
							GeometryReader { (innerGeometry) in
								Color.clear
									.onAppear {
										self.height = innerGeometry.size.height
									}
							}
						)
				}
				if self.height >= outerGeometry.frame(in: .local).size.height {
					Rectangle()
						.fill(
							LinearGradient(
								colors: [
									self.fadeColor,
									self.fadeColor
										.opacity(0.1)
								],
								startPoint: .top,
								endPoint: .bottom
							)
						)
						.frame(height: outerGeometry.frame(in: .global).size.height / 3)
						.position(
							CGPoint(
								x: outerGeometry.frame(in: .global).size.width / 2,
								y: outerGeometry.frame(in: .global).size.height / 100
							)
						)
					Rectangle()
						.fill(
							LinearGradient(
								colors: [
									self.fadeColor
										.opacity(0.1),
									self.fadeColor
								],
								startPoint: .top,
								endPoint: .bottom
							)
						)
						.frame(height: outerGeometry.frame(in:.global).size.height / 3)
						.position(
							CGPoint(
								x: outerGeometry.frame(in: .global).size.width / 2,
								y: outerGeometry.frame(in: .global).size.height - (outerGeometry.frame(in: .global).size.height / 15)
							)
						)
				}
			}
		}
	}
	
	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
	
}

#Preview {
	FadeScrollView {
		ForEach(0 ..< 100) { (_) in
			Text("Hello, world!")
		}
	}
}
