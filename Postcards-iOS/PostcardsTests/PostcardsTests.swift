import XCTest
@testable import Postcards

final class PostcardsTests: XCTestCase {
    
    func testColorHexInit() {
        let color = PostcardColors.stampRed
        XCTAssertNotNil(color)
    }
    
    func testTravelModelCreation() {
        let travel = Travel(
            title: "日本之旅",
            destination: "东京",
            startDate: Date()
        )
        XCTAssertEqual(travel.destination, "东京")
        XCTAssertEqual(travel.status, .ongoing)
    }
    
    func testPostcardModelCreation() {
        let postcard = Postcard(
            locationName: "东京塔",
            recordedAt: Date()
        )
        XCTAssertEqual(postcard.locationName, "东京塔")
        XCTAssertFalse(postcard.isFavorite)
    }
    
    func testAPIEndpointPaths() {
        let travelsEndpoint = Endpoint.travels()
        XCTAssertEqual(travelsEndpoint.path, "/api/v1/travels")
        XCTAssertEqual(travelsEndpoint.method, .get)
    }
}
