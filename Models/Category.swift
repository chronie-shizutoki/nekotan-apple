//
//  Category.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import Foundation

/// Category Model
/// Model representing a diary category in the application
struct Category: Identifiable, Codable, Hashable {
    /// Unique identifier (using name as ID)
    var id: String { name }
    
    /// Category name
    var name: String
    
    /// Number of diary entries in this category
    var count: Int = 0
    
    /// Creates a new category
    /// - Parameters:
    ///   - name: Category name
    ///   - count: Number of diary entries in this category, defaults to 0
    init(name: String, count: Int = 0) {
        self.name = name
        self.count = count
    }
    
    // MARK: - Static Properties and Methods
    
    /// Creates an example category (for preview purposes)
    static var example: Category {
        Category(name: "日常", count: 5)
    }
    
    /// Creates the default categories list
    static func createDefaultCategories() -> [Category] {
        return DiaryEntry.defaultCategories.map { Category(name: $0) }
    }
}