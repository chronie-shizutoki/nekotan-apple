//
//  Tag.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import Foundation

/// Tag Model
/// Model representing a diary tag in the application
struct Tag: Identifiable, Codable, Hashable {
    /// Unique identifier (using name as ID)
    var id: String { name }
    
    /// Tag name
    var name: String
    
    /// Number of diary entries with this tag
    var count: Int = 0
    
    /// Creates a new tag
    /// - Parameters:
    ///   - name: Tag name
    ///   - count: Number of diary entries with this tag, defaults to 0
    init(name: String, count: Int = 0) {
        self.name = name
        self.count = count
    }
    
    // MARK: - Static Properties and Methods
    
    /// Creates an example tag (for preview purposes)
    static var example: Tag {
        Tag(name: "楽しい", count: 3)
    }
    
    /// Creates example tags list (for preview purposes)
    static var examples: [Tag] {
        [
            Tag(name: "楽しい", count: 3),
            Tag(name: "公園", count: 2),
            Tag(name: "ご飯", count: 5),
            Tag(name: "猫", count: 10),
            Tag(name: "散歩", count: 4)
        ]
    }
}