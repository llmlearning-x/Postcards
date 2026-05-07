import Foundation
import SwiftData

@Model
final class Travel {
    @Attribute(.unique) var id: UUID
    var title: String
    var destination: String
    var startDate: Date
    var endDate: Date?
    var status: TravelStatus
    var isCurrent: Bool
    var coverImageURL: String?
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Postcard.travel)
    var postcards: [Postcard]?
    
    enum TravelStatus: String, Codable {
        case ongoing = "ONGOING"
        case completed = "COMPLETED"
        case planned = "PLANNED"
    }
    
    init(title: String, destination: String, startDate: Date, isCurrent: Bool = true) {
        self.id = UUID()
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.status = .ongoing
        self.isCurrent = isCurrent
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class Postcard {
    @Attribute(.unique) var id: UUID
    var travelID: UUID?
    var photos: [String] // URLs
    var locationName: String
    var locationLat: Double?
    var locationLng: Double?
    var country: String?
    var city: String?
    var recordedAt: Date
    var weatherCondition: String?
    var weatherTemp: Double?
    var note: String?
    var tags: [String]
    var isFavorite: Bool
    var createdAt: Date
    
    @Relationship
    var travel: Travel?
    
    init(locationName: String, recordedAt: Date) {
        self.id = UUID()
        self.photos = []
        self.locationName = locationName
        self.recordedAt = recordedAt
        self.tags = []
        self.isFavorite = false
        self.createdAt = Date()
    }
}

@Model
final class UserStats {
    var totalCities: Int
    var totalPostcards: Int
    var totalCountries: Int
    var joinedDays: Int
    
    init() {
        self.totalCities = 0
        self.totalPostcards = 0
        self.totalCountries = 0
        self.joinedDays = 0
    }
}
