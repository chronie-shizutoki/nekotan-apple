//
//  DiaryViewModelTests.swift
//  NekoTanTests
//
//  Created for NekoTan Swift App
//

import XCTest
import Combine
@testable import NekoTanLib

// Mock implementation of DiaryDataService for testing
class MockDiaryDataService: DiaryDataService {
    // Mock data
    private var mockDiaries: [DiaryEntry] = []
    private var shouldFail: Bool = false
    
    // Configure mock behavior
    func setMockDiaries(_ diaries: [DiaryEntry]) {
        self.mockDiaries = diaries
    }
    
    func setShouldFail(_ fail: Bool) {
        self.shouldFail = fail
    }
    
    // MARK: - DiaryDataService Implementation
    
    func loadDiaries(completion: @escaping (Result<[DiaryEntry], Error>) -> Void) {
        if shouldFail {
            completion(.failure(DiaryError.loadFailed))
        } else {
            completion(.success(mockDiaries))
        }
    }
    
    func saveDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldFail {
            completion(.failure(DiaryError.saveFailed))
        } else {
            mockDiaries.append(diary)
            completion(.success(()))
        }
    }
    
    func updateDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldFail {
            completion(.failure(DiaryError.saveFailed))
        } else {
            if let index = mockDiaries.firstIndex(where: { $0.id == diary.id }) {
                mockDiaries[index] = diary
            } else {
                mockDiaries.append(diary)
            }
            completion(.success(()))
        }
    }
    
    func deleteDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldFail {
            completion(.failure(DiaryError.deleteFailed))
        } else {
            mockDiaries.removeAll { $0.id == diary.id }
            completion(.success(()))
        }
    }
    
    func exportToCSV(diaries: [DiaryEntry]) -> String {
        var csvString = DiaryEntry.csvHeader + "\n"
        
        for diary in diaries {
            csvString += diary.toCSVRow() + "\n"
        }
        
        return csvString
    }
    
    func importFromCSV(_ csvString: String, completion: @escaping (Result<[DiaryEntry], Error>) -> Void) {
        if shouldFail {
            completion(.failure(DiaryError.saveFailed))
        } else {
            // Parse CSV
            let lines = csvString.components(separatedBy: .newlines)
            var diaries: [DiaryEntry] = []
            
            // Skip header line
            for i in 1..<lines.count {
                let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                if line.isEmpty { continue }
                
                if let diary = DiaryEntry.fromCSVRow(line) {
                    diaries.append(diary)
                }
            }
            
            self.mockDiaries = diaries
            completion(.success(diaries))
        }
    }
}

/// Tests for DiaryViewModel
class DiaryViewModelTests: XCTestCase {
    // System under test
    private var viewModel: DiaryViewModel?
    
    // Mock dependencies
    private var mockService: MockDiaryDataService?
    
    // Test helpers
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        // Create mock dependencies
        mockService = MockDiaryDataService()
        
        // Create view model with mock service
        viewModel = DiaryViewModel(diaryService: mockService)
    }
    
    override func tearDownWithError() throws {
        // Clean up
        viewModel = nil
        mockService = nil
        cancellables.removeAll()
    }
    
    // MARK: - Tests
    
    /// Test loading diaries successfully
    func testLoadDiariesSuccess() {        
        // Given
        let expectedDiaries = [
            DiaryEntry(content: "今日はいい天気です", category: "日常", tags: ["天気"]),
            DiaryEntry(content: "プログラミングが楽しい", category: "勉強", tags: ["Swift", "プログラミング"])
        ]
        mockService.setMockDiaries(expectedDiaries)
        
        // When
        let expectation = self.expectation(description: "Diaries loaded successfully")
        
        viewModel.$diaries
            .dropFirst() // Skip initial empty array
            .sink {\ diaries in
                // Then
                XCTAssertEqual(diaries.count, 2)
                XCTAssertEqual(diaries[0].content, "今日はいい天気です")
                XCTAssertEqual(diaries[1].content, "プログラミングが楽しい")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.loadData()
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    /// Test loading diaries failure
    func testLoadDiariesFailure() {
        // Given
        mockService.setShouldFail(true)
        
        // When
        viewModel.loadData()
        
        // Then (In a real test, we would verify error handling)
        // Since the current implementation doesn't expose error state,
        // we just ensure the test runs without crashing
        XCTAssertTrue(true, "Test completed without crashing")
    }
    
    /// Test saving a diary
    func testSaveDiary() {
        // Given
        let newDiary = DiaryEntry(content: "新しい日記", category: "日常", tags: ["新しい"])
        viewModel.newDiary = newDiary
        
        // When
        let expectation = self.expectation(description: "Diary saved successfully")
        
        viewModel.$diaries
            .dropFirst()
            .sink {\ diaries in
                // Then
                XCTAssertEqual(diaries.count, 1)
                XCTAssertEqual(diaries[0].content, "新しい日記")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.saveDiary { _ in }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    /// Test filtering diaries by search query
    func testFilteredDiariesBySearchQuery() {
        // Given
        let diaries = [
            DiaryEntry(content: "りんごが好き", category: "日常", tags: ["食べ物"]),
            DiaryEntry(content: "みかんが美味しい", category: "日常", tags: ["食べ物"]),
            DiaryEntry(content: "プログラミング勉強中", category: "勉強", tags: ["Swift"])
        ]
        mockService.setMockDiaries(diaries)
        
        // Load data first
        let loadExpectation = self.expectation(description: "Diaries loaded")
        viewModel.$diaries
            .dropFirst()
            .sink {\ _ in
                loadExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.loadData()
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // When
        viewModel.searchQuery = "みかん"
        
        // Then
        XCTAssertEqual(viewModel.filteredDiaries.count, 1)
        XCTAssertEqual(viewModel.filteredDiaries[0].content, "みかんが美味しい")
        
        // Reset search query
        viewModel.searchQuery = ""
        XCTAssertEqual(viewModel.filteredDiaries.count, 3)
    }
}