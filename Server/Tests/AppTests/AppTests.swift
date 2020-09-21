import XCTVapor
@testable import App

final class AppTests: XCTestCase {
	
	func testHelloWorld() throws {
		let app = Application(.testing)
		defer {
			app.shutdown()
			
		}
		try configure(app)
		try app.test(.GET, "hello") { (response) in
			XCTAssertEqual(response.status, .ok)
			XCTAssertEqual(response.body.string, "Hello, world!")
		}
	}
	
}
