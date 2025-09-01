//
//  ContentViewTests.swift
//  NekoTanUITests
//
//  Created for NekoTan Swift App
//

import XCTest

/// UI tests for ContentView
class ContentViewTests: XCTestCase {
    // The XCUIApplication instance representing the app under test
    private var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        // Continue after failure
        continueAfterFailure = false
        
        // Launch the application
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"] // Optional: Add launch arguments for UI testing mode
        app.launch()
        
        // Give the app time to load
        sleep(1)
    }
    
    override func tearDownWithError() throws {
        // Clean up
        app = nil
    }
    
    // MARK: - Tests
    
    /// Test that the main interface elements are present
    func testMainInterfaceElementsExist() {
        // Check that the main UI elements are present
        XCTAssertTrue(app.staticTexts["NekoTan"].exists, "App title should be displayed")
        
        // Verify that the diary list exists
        let diaryList = app.tables["diaryList"]
        XCTAssertTrue(diaryList.exists, "Diary list should be displayed")
        
        // Verify that the add button exists
        let addButton = app.buttons["addButton"]
        XCTAssertTrue(addButton.exists, "Add button should be displayed")
    }
    
    /// Test adding a new diary entry
    func testAddNewDiaryEntry() {
        // Tap the add button
        let addButton = app.buttons["addButton"]
        addButton.tap()
        
        // Check that the edit view appears
        let editView = app.scrollViews["diaryEditView"]
        XCTAssertTrue(editView.waitForExistence(timeout: 1.0), "Edit view should appear after tapping add button")
        
        // Enter diary content
        let contentTextField = app.textViews["contentTextField"]
        XCTAssertTrue(contentTextField.exists, "Content text field should exist")
        contentTextField.tap()
        contentTextField.typeText("UIテストからの日記エントリー")
        
        // Select category
        let categoryField = app.textFields["categoryTextField"]
        XCTAssertTrue(categoryField.exists, "Category field should exist")
        categoryField.tap()
        categoryField.typeText("テスト")
        
        // Tap save button
        let saveButton = app.buttons["saveButton"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        saveButton.tap()
        
        // Check that we're back to the main view and the new diary is displayed
        let diaryList = app.tables["diaryList"]
        XCTAssertTrue(diaryList.waitForExistence(timeout: 1.0), "Should return to main list after saving")
        
        // Verify the new diary entry is displayed
        let newDiaryCell = diaryList.cells.containing(.staticText, identifier:"UIテストからの日記エントリー").firstMatch
        XCTAssertTrue(newDiaryCell.exists, "New diary entry should be displayed in the list")
    }
    
    /// Test searching for diary entries
    func testSearchDiaryEntries() {
        // First, add a diary entry to search for
        addTestDiaryEntry(content: "検索テスト用日記", category: "検索")
        
        // Access the search bar
        let searchBar = app.searchFields["searchBar"]
        XCTAssertTrue(searchBar.exists, "Search bar should exist")
        searchBar.tap()
        searchBar.typeText("検索")
        
        // Check that the matching diary is displayed
        let diaryList = app.tables["diaryList"]
        let searchResultCell = diaryList.cells.containing(.staticText, identifier:"検索テスト用日記").firstMatch
        XCTAssertTrue(searchResultCell.exists, "Search should find matching diary entry")
        
        // Clear search
        searchBar.buttons["clearSearchButton"].tap()
    }
    
    // MARK: - Helper Methods
    
    /// Helper method to add a test diary entry
    private func addTestDiaryEntry(content: String, category: String, tags: String = "") {
        // Tap the add button
        let addButton = app.buttons["addButton"]
        addButton.tap()
        
        // Wait for edit view
        let editView = app.scrollViews["diaryEditView"]
        XCTAssertTrue(editView.waitForExistence(timeout: 1.0), "Edit view should appear")
        
        // Enter content
        let contentTextField = app.textViews["contentTextField"]
        contentTextField.tap()
        contentTextField.typeText(content)
        
        // Enter category
        let categoryField = app.textFields["categoryTextField"]
        categoryField.tap()
        categoryField.typeText(category)
        
        // Enter tags if provided
        if !tags.isEmpty {
            let tagsField = app.textFields["tagsTextField"]
            tagsField.tap()
            tagsField.typeText(tags)
        }
        
        // Save
        let saveButton = app.buttons["saveButton"]
        saveButton.tap()
        
        // Wait for main view to reappear
        let diaryList = app.tables["diaryList"]
        XCTAssertTrue(diaryList.waitForExistence(timeout: 1.0), "Should return to main list")
    }
}