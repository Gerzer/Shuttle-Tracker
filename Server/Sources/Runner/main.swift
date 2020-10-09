//
//  main.swift
//
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import Vapor
import App

var environment = try Environment.detect()
try LoggingSystem.bootstrap(from: &environment)
let app = Application(environment)
defer {
	app.shutdown()
}
try configure(app)
try app.run()
