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
		),
		.package(
			name: "QueuesFluentDriver",
			url: "https://github.com/m-barthelemy/vapor-queues-fluent-driver.git",
			from: "1.0.0-rc.2"
		),
		.package(
			url: "https://github.com/Gerzer/JSONParser.git",
			.branch("main")
		)
	],
	targets: [
		.target(
			name: "App",
			dependencies: [
				.product(
					name: "Vapor",
					package: "vapor"
				),
				.product(
					name: "Fluent",
					package: "fluent"
				),
				.product(
					name: "FluentSQLiteDriver",
					package: "fluent-sqlite-driver"
				),
				.product(
					name: "QueuesFluentDriver",
					package: "QueuesFluentDriver"
				),
				.product(
					name: "JSONParser",
					package: "JSONParser"
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
			name: "Runner",
			dependencies: [
				.target(
					name: "App"
				)
			]
		)
	]
)
