//
//  DiaryDataService.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import Foundation

// Import shared error types
import DiaryError

/// Protocol defining diary data operations
protocol DiaryDataService {
    /// Loads all diary entries
    /// - Parameter completion: Callback with result containing diary entries or error
    func loadDiaries(completion: @escaping (Result<[DiaryEntry], Error>) -> Void)
    
    /// Saves a new diary entry
    /// - Parameters:
    ///   - diary: The diary entry to save
    ///   - completion: Callback with result of the operation
    func saveDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Updates an existing diary entry
    /// - Parameters:
    ///   - diary: The diary entry to update
    ///   - completion: Callback with result of the operation
    func updateDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Deletes a diary entry
    /// - Parameters:
    ///   - diary: The diary entry to delete
    ///   - completion: Callback with result of the operation
    func deleteDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Exports diaries to CSV format
    /// - Parameter diaries: Diary entries to export
    /// - Returns: CSV string representation
    func exportToCSV(diaries: [DiaryEntry]) -> String
    
    /// Imports diaries from CSV format
    /// - Parameters:
    ///   - csvString: CSV string containing diary entries
    ///   - completion: Callback with result containing diary entries or error
    func importFromCSV(_ csvString: String, completion: @escaping (Result<[DiaryEntry], Error>) -> Void)
}