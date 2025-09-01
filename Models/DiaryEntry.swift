//
//  DiaryEntry.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import Foundation

/// Diary Entry Model
/// Model representing a diary entry in the application
struct DiaryEntry: Identifiable, Codable, Hashable {
    /// Unique identifier for the diary entry
    var id: Int64
    
    /// Creation date of the diary entry
    var date: Date
    
    /// Content of the diary entry
    var content: String
    
    /// Category of the diary entry
    var category: String
    
    /// List of tags associated with the diary entry
    var tags: [String]
    
    /// Creates a new diary entry
    /// - Parameters:
    ///   - id: Unique identifier, defaults to current timestamp
    ///   - date: Creation date, defaults to current date
    ///   - content: Content of the diary entry
    ///   - category: Category, defaults to "未分類" (Uncategorized)
    ///   - tags: List of tags, defaults to empty array
    init(
        id: Int64 = Int64(Date().timeIntervalSince1970 * 1000),
        date: Date = Date(),
        content: String,
        category: String = "未分類",
        tags: [String] = []
    ) {
        self.id = id
        self.date = date
        self.content = content
        self.category = category
        self.tags = tags
    }
    
    // MARK: - Computed Properties
    
    /// Formatted date string (medium format)
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Short formatted date string (date only)
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Checks if the diary entry is empty
    var isEmpty: Bool {
        return content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Static Properties and Methods
    
    /// Default categories list
    static let defaultCategories = [
        "未分類",
        "日常", // Daily life
        "仕事", // Work
        "勉強", // Study
        "趣味", // Hobbies
        "思考", // Thinking
        "旅行", // Travel
        "健康", // Health
        "創作", // Creation
        "読書", // Reading
        "料理", // Cooking
        "夢", // Dream
        "目標", // Goal
        "映画", // Movie
        "ゲーム", // Game
        "音楽" // Music
    ]
    
    /// Creates an example diary entry (for preview purposes)
    static var example: DiaryEntry {
        DiaryEntry(
            id: 1,
            date: Date(),
            content: "今日はとても楽しかったにゃん～♪ 公園で遊んだり、おいしいご飯を食べたりしたにゃ～！明日も素敵な一日になりますように～♡",
            category: "日常",
            tags: ["楽しい", "公園", "ご飯"]
        )
    }
}

// MARK: - CSV Conversion Extension
extension DiaryEntry {
    /// Converts the diary entry to a CSV row
    func toCSVRow() -> String {
        let escapedContent = content.replacingOccurrences(of: "\"", with: "\"\"")
        let escapedCategory = category.replacingOccurrences(of: "\"", with: "\"\"")
        let escapedTags = tags.joined(separator: ";").replacingOccurrences(of: "\"", with: "\"\"")
        
        return "\\(id),\"\\(date.ISO8601Format())\",\"\\(escapedContent)\",\"\\(escapedCategory)\",\"\\(escapedTags)\""
    }
    
    /// Creates a diary entry from a CSV row
    /// - Parameter csvRow: CSV row string
    /// - Returns: Diary entry, or nil if parsing fails
    static func fromCSVRow(_ csvRow: String) -> DiaryEntry? {
        let components = csvRow.split(separator: ",", omittingEmptySubsequences: false)
        guard components.count >= 5 else { return nil }
        
        // Parse ID
        guard let id = Int64(components[0]) else { return nil }
        
        // Parse date
        let dateString = String(components[1]).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        
        // Parse content, category and tags
        let content = String(components[2]).trimmingCharacters(in: CharacterSet(charactersIn: "\"")).replacingOccurrences(of: "\"\"", with: "\"")
        let category = String(components[3]).trimmingCharacters(in: CharacterSet(charactersIn: "\"")).replacingOccurrences(of: "\"\"", with: "\"")
        let tagsString = String(components[4]).trimmingCharacters(in: CharacterSet(charactersIn: "\"")).replacingOccurrences(of: "\"\"", with: "\"")
        let tags = tagsString.isEmpty ? [] : tagsString.split(separator: ";").map { String($0) }
        
        return DiaryEntry(id: id, date: date, content: content, category: category, tags: tags.map { String($0) })
    }
    
    /// Generates CSV header
    static var csvHeader: String {
        return "id,date,content,category,tags"
    }
}