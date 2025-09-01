//
//  DiaryViewModel.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import Foundation
import Combine

// Import shared error types
import DiaryError

/// ViewModel for managing diary entries
class DiaryViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// All diary entries
    @Published var diaries: [DiaryEntry] = []
    
    /// Categories with usage count
    @Published var categories: [Category] = []
    
    /// Tags with usage count
    @Published var tags: [Tag] = []
    
    /// Currently selected diary for editing
    @Published var selectedDiary: DiaryEntry?
    
    /// New diary entry being composed
    @Published var newDiary: DiaryEntry = DiaryEntry(content: "")
    
    /// Search query for filtering diaries
    @Published var searchQuery: String = ""
    
    /// Selected category for filtering
    @Published var selectedCategory: String = ""
    
    /// Selected tag for filtering
    @Published var selectedTag: String = ""
    
    /// Notification message to display
    @Published var notification: String? = nil
    
    // MARK: - Private Properties
    
    /// Service for data operations
    private let diaryService: DiaryDataService
    
    /// Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Initializes the view model with a data service
    /// - Parameter diaryService: Service for diary data operations
    init(diaryService: DiaryDataService = DiaryDataManager()) {
        self.diaryService = diaryService
        loadData()
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Loads all diary data
    func loadData() {
        diaryService.loadDiaries { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let diaries):
                DispatchQueue.main.async {
                    self.diaries = diaries
                    self.updateCategoriesAndTags()
                }
            case .failure(let error):
                print("Error loading diaries: \(error.localizedDescription)")
                // TODO: Handle error properly with alert
            }
        }
    }
    
    /// Saves a new diary entry
    /// - Parameter completion: Callback with result of the operation
    func saveDiary(completion: @escaping (Result<Void, Error>) -> Void) {
        // Don't save empty diaries
        guard !newDiary.isEmpty else {
            completion(.failure(DiaryError.emptyContent))
            return
        }
        
        diaryService.saveDiary(newDiary) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // Add to local collection if not already present
                    if !self.diaries.contains(where: { $0.id == self.newDiary.id }) {
                        self.diaries.append(self.newDiary)
                    }
                    
                    // Reset new diary
                    self.newDiary = DiaryEntry(content: "")
                    
                    // Update categories and tags
                    self.updateCategoriesAndTags()
                    
                    // Show notification
                    self.showNotification("日記が保存されました～♡") // Diary saved!
                    
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Updates an existing diary entry
    /// - Parameters:
    ///   - diary: The diary entry to update
    ///   - completion: Callback with result of the operation
    func updateDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        // Don't update with empty content
        guard !diary.isEmpty else {
            completion(.failure(DiaryError.emptyContent))
            return
        }
        
        diaryService.updateDiary(diary) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // Update in local collection
                    if let index = self.diaries.firstIndex(where: { $0.id == diary.id }) {
                        self.diaries[index] = diary
                    }
                    
                    // Update categories and tags
                    self.updateCategoriesAndTags()
                    
                    // Show notification
                    self.showNotification("日記が更新されました～♪") // Diary updated!
                    
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Deletes a diary entry
    /// - Parameters:
    ///   - diary: The diary entry to delete
    ///   - completion: Callback with result of the operation
    func deleteDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        diaryService.deleteDiary(diary) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // Remove from local collection
                    self.diaries.removeAll { $0.id == diary.id }
                    
                    // Update categories and tags
                    self.updateCategoriesAndTags()
                    
                    // Show notification
                    self.showNotification("日記が削除されました～") // Diary deleted!
                    
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Exports diaries to CSV format
    /// - Returns: CSV string representation of all diaries
    func exportToCSV() -> String {
        return diaryService.exportToCSV(diaries: diaries)
    }
    
    /// Imports diaries from CSV format
    /// - Parameters:
    ///   - csvString: CSV string containing diary entries
    ///   - completion: Callback with result of the operation
    func importFromCSV(_ csvString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        diaryService.importFromCSV(csvString) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let diaries):
                DispatchQueue.main.async {
                    self.diaries = diaries
                    self.updateCategoriesAndTags()
                    
                    // Show notification
                    self.showNotification("日記がインポートされました～✨") // Diaries imported!
                    
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Filtered diaries based on search query, selected category and tag
    var filteredDiaries: [DiaryEntry] {
        diaries.filter { diary in
            let matchesSearch = searchQuery.isEmpty || 
                diary.content.localizedCaseInsensitiveContains(searchQuery) ||
                diary.category.localizedCaseInsensitiveContains(searchQuery) ||
                diary.tags.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
            
            let matchesCategory = selectedCategory.isEmpty || diary.category == selectedCategory
            
            let matchesTag = selectedTag.isEmpty || diary.tags.contains(selectedTag)
            
            return matchesSearch && matchesCategory && matchesTag
        }.sorted { $0.date > $1.date } // Sort by date, newest first
    }
    
    // MARK: - Private Methods
    
    /// Sets up data bindings
    private func setupBindings() {
        // Example of potential future bindings
        // This could be used to react to changes in published properties
    }
    
    /// Shows a notification message
    /// - Parameter message: The message to display
    private func showNotification(_ message: String) {
        self.notification = message
        
        // Hide notification after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.notification = nil
        }
    }
    
    /// Updates categories and tags based on current diaries
    private func updateCategoriesAndTags() {
        // Count categories
        var categoryDict: [String: Int] = [:]
        for diary in diaries {
            categoryDict[diary.category, default: 0] += 1
        }
        
        // Create category objects
        categories = categoryDict.map { Category(name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count } // Sort by usage count
        
        // Add default categories if not present
        for defaultCategory in DiaryEntry.defaultCategories {
            if !categories.contains(where: { $0.name == defaultCategory }) {
                categories.append(Category(name: defaultCategory))
            }
        }
        
        // Count tags
        var tagDict: [String: Int] = [:]
        for diary in diaries {
            for tag in diary.tags {
                tagDict[tag, default: 0] += 1
            }
        }
        
        // Create tag objects
        tags = tagDict.map { Tag(name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count } // Sort by usage count
    }
}

// Import shared error types
import Foundation