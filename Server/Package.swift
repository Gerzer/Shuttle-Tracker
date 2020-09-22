// swift-tools-version:5.3
import PackageDescription

let package = Package(
	name: "Rensselaer Shuttle Server",
	platforms: [
		.macOS(
			.v10_15
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/vapor/vapor.git",
			from: "4.0.0"
		),
		.package(
			url: "https://github.com/vapor/fluent.git",
			from: "4.0.0"
		),
		.package(
			url:"https://github.com/vapor/fluent-sqlite-driver.git",
			from: "4.0.0"
		)
	],
	targets: [
		.target(
			name: "App",
			dependencies: [
				.product(
					 name: "Fluent",
					package: "fluent"
				),
				.product(
					name: "FluentSQLiteDriver",
					package: "fluent-sqlite-driver"
				),
				.product(
					name: "Vapor",
					package: "vapor"
				)
			],
			swiftSettings: [
				.unsafeFlags(
					[
						"-cross-module-optimization"
					],
					.when(
						configuration: .release
					)
				)
			]
		),
		.target(
			name: "Run",
			dependencies: [
				.target(
					name: "App"
				)
			]
		)
	]
)
