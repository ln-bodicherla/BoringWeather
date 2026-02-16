import XCTest

final class BoringWeatherUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Tab Navigation Tests

    func testTabBarExists() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }

    func testNavigateToLocationsTab() {
        let locationsTab = app.tabBars.buttons["Locations"]
        XCTAssertTrue(locationsTab.exists)
        locationsTab.tap()

        // Should show search field or locations list
        let searchField = app.textFields["Search city..."]
        // Search field may exist; we just verify navigation worked
        XCTAssertTrue(locationsTab.isSelected)
    }

    func testNavigateToAlertsTab() {
        let alertsTab = app.tabBars.buttons["Alerts"]
        XCTAssertTrue(alertsTab.exists)
        alertsTab.tap()
        XCTAssertTrue(alertsTab.isSelected)
    }

    func testNavigateToSettingsTab() {
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
        XCTAssertTrue(settingsTab.isSelected)
    }

    func testNavigateBackToHome() {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        let homeTab = app.tabBars.buttons["Home"]
        homeTab.tap()
        XCTAssertTrue(homeTab.isSelected)
    }

    // MARK: - Settings Tests

    func testSettingsContainsUnitPresets() {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Check for unit preset text
        let metricText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Metric'")).firstMatch
        XCTAssertTrue(metricText.waitForExistence(timeout: 3))
    }

    // MARK: - Search Flow Tests

    func testSearchBarExistsOnLocations() {
        let locationsTab = app.tabBars.buttons["Locations"]
        locationsTab.tap()

        // Look for the search text field
        let searchField = app.textFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
    }
}
