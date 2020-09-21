import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {
//	app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
	app.databases.use(.sqlite(.memory), as: .sqlite)
	app.migrations.add(CreateBuses())
	try app.autoMigrate().wait()
	try routes(app)
}
