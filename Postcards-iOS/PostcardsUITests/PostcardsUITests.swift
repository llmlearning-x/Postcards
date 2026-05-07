import XCTest

final class PostcardsUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_IN_MEMORY_STORE")
        app.launch()
        return app
    }
    
    func testTabBarNavigation() throws {
        let app = launchApp()
        
        // Verify all tabs exist
        XCTAssertTrue(app.buttons["首页"].exists)
        XCTAssertTrue(app.buttons["时间轴"].exists)
        XCTAssertTrue(app.buttons["地图"].exists)
        XCTAssertTrue(app.buttons["收藏"].exists)
        XCTAssertTrue(app.buttons["我的"].exists)
        
        // Navigate through tabs
        app.buttons["时间轴"].tap()
        app.buttons["地图"].tap()
        app.buttons["收藏"].tap()
        app.buttons["我的"].tap()
        app.buttons["首页"].tap()
    }
    
    func testCreateTravelAndSavePostcardToTimeline() throws {
        let app = launchApp()

        app.buttons["CreateTravelButton"].tap()

        let titleField = app.textFields["TravelTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("日本之旅")

        let destinationField = app.textFields["TravelDestinationField"]
        destinationField.tap()
        destinationField.typeText("东京")

        app.buttons["SaveTravelButton"].tap()

        let recordButton = app.buttons["RecordButton"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 2))
        recordButton.tap()

        let textMethodButton = app.buttons["RecordMethodText"]
        XCTAssertTrue(textMethodButton.waitForExistence(timeout: 2))
        textMethodButton.tap()

        let locationField = app.textFields["RecordLocationField"]
        XCTAssertTrue(locationField.waitForExistence(timeout: 2))
        locationField.tap()
        locationField.typeText("东京塔")

        let noteEditor = app.textViews["RecordNoteEditor"]
        XCTAssertTrue(noteEditor.waitForExistence(timeout: 2))
        noteEditor.tap()
        noteEditor.typeText("夜景很漂亮")

        app.buttons["GeneratePostcardButton"].tap()

        let savePostcardButton = app.buttons["SavePostcardButton"]
        XCTAssertTrue(savePostcardButton.waitForExistence(timeout: 2))
        savePostcardButton.tap()

        app.buttons["时间轴"].tap()
        XCTAssertTrue(app.staticTexts["东京塔"].waitForExistence(timeout: 2))
    }
}
