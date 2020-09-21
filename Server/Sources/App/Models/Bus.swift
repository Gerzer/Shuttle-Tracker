import Vapor
import Fluent

final class Bus: Model, Content {
	
	struct Location: Identifiable, Hashable, Codable, Content {
		
		var id: UUID
		var latitude: Double
		var longitude: Double
		
	}
	
	static let schema = "buses"
	
	@ID(custom: "id", generatedBy: .user) var id: Int?
	@Field(key: "locations") var locations: [Location]
	
	init() { }
	
	init(id: Int, locations: [Location] = []) {
		self.id = id
		self.locations = locations
	}
	
}
