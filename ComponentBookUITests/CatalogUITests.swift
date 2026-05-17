import XCTest

/// End-to-end UI tests covering the catalog navigation and the most important
/// interactions for each component.
final class CatalogUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Catalog root

    @MainActor
    func test_catalogRoot_listsBothComponents() {
        XCTAssertTrue(app.staticTexts["Button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Text field"].exists)
    }

    // MARK: - Button gallery

    @MainActor
    func test_buttonGallery_tappingPrimaryUpdatesTicker() {
        app.staticTexts["Button"].tap()

        let primary = app.buttons["Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 3))
        primary.tap()

        XCTAssertTrue(app.staticTexts["Tapped: Primary"].waitForExistence(timeout: 2))
    }

    @MainActor
    func test_buttonGallery_disabledButton_isNotEnabled() {
        app.staticTexts["Button"].tap()

        let disabled = app.buttons["Disabled"]
        XCTAssertTrue(disabled.waitForExistence(timeout: 3))
        XCTAssertFalse(disabled.isEnabled, "Disabled button should not be tappable")
    }

    @MainActor
    func test_buttonGallery_iconOnlyFavorite_isAccessibleByOverrideLabel() {
        app.staticTexts["Button"].tap()
        // Icon-only buttons in the gallery use Configuration.accessibilityLabel
        // overrides so VoiceOver reads "Favorite" / "Share" / "Delete" instead
        // of SF Symbol names. The element lives in the Icons section, below the
        // initial scroll fold — assert existence in the hierarchy rather than
        // hit-testing it without scrolling.
        let favorite = app.buttons["Favorite"]
        XCTAssertTrue(favorite.waitForExistence(timeout: 5))
    }

    // MARK: - Text field gallery

    @MainActor
    func test_textFieldGallery_searchField_clearButtonClearsText() {
        app.staticTexts["Text field"].tap()

        let searchField = app.textFields["Search the catalog"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("hello")

        // CBTextField exposes the clear affordance under the documented VoiceOver label.
        let clearButton = app.buttons["Clear text"]
        XCTAssertTrue(clearButton.waitForExistence(timeout: 2))
        clearButton.tap()

        // After clearing, the placeholder is the field's reported value again.
        XCTAssertEqual(searchField.value as? String, "Search the catalog")
    }

    @MainActor
    func test_textFieldGallery_phoneField_acceptsTyping() {
        app.staticTexts["Text field"].tap()

        // The Phone field has the unique placeholder "Optional" and starts
        // empty — the two Email-placeholder fields would collide on
        // firstMatch (one is prefilled with "not-an-email" to demo the error
        // validation state, so typeText would append instead of replace).
        let phoneField = app.textFields["Optional"]
        XCTAssertTrue(phoneField.waitForExistence(timeout: 3))
        phoneField.tap()
        phoneField.typeText("555-1234")

        XCTAssertEqual(phoneField.value as? String, "555-1234")
    }

    @MainActor
    func test_textFieldGallery_validationErrorField_isPrefilledWithInvalidValue() {
        app.staticTexts["Text field"].tap()

        // The Email field in the Validation section ships prefilled with an
        // invalid value so the .error state has something to flag.
        let invalidEmail = app.textFields["you@example.com"].firstMatch
        XCTAssertTrue(invalidEmail.waitForExistence(timeout: 3))
        XCTAssertEqual(invalidEmail.value as? String, "not-an-email")
    }
}
