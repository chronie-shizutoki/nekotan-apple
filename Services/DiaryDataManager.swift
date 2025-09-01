//
//  DiaryDataManager.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import Foundation
import CoreData

/// Implementation of DiaryDataService using CoreData and file-based storage
class DiaryDataManager: DiaryDataService {
    // MARK: - Private Properties
    
    /// File URL for CSV backup
    private let csvFileURL: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("diaries.csv")
    }()
    
    /// CoreData persistent container
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NekoTanModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error appropriately
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    /// CoreData managed object context
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    
    init() {
        // Setup initial data if needed
        createBackupDirectoryIfNeeded()
    }
    
    // MARK: - DiaryDataService Implementation
    
    func loadDiaries(completion: @escaping (Result<[DiaryEntry], Error>) -> Void) {
        // First try to load from CoreData
        do {
            let fetchRequest: NSFetchRequest<CDDiaryEntry> = CDDiaryEntry.fetchRequest()
            let cdDiaries = try context.fetch(fetchRequest)
            
            if !cdDiaries.isEmpty {
                // Convert CoreData objects to DiaryEntry models
                let diaries = cdDiaries.compactMap { cdDiary -> DiaryEntry? in
                    guard let date = cdDiary.date,
                          let content = cdDiary.content,
                          let category = cdDiary.category else {
                        return nil
                    }
                    
                    let tags = cdDiary.tags?.components(separatedBy: ";") ?? []
                    return DiaryEntry(
                        id: cdDiary.id,
                        date: date,
                        content: content,
                        category: category,
                        tags: tags
                    )
                }
                completion(.success(diaries))
                return
            }
        } catch {
            print("Error loading from CoreData: \(error.localizedDescription)")
            // Continue to try CSV as fallback
        }
        
        // Fallback to CSV file if CoreData is empty or fails
        loadFromCSV(completion: completion)
    }
    
    func saveDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        // Save to CoreData
        let cdDiary = CDDiaryEntry(context: context)
        cdDiary.id = diary.id
        cdDiary.date = diary.date
        cdDiary.content = diary.content
        cdDiary.category = diary.category
        cdDiary.tags = diary.tags.joined(separator: ";")
        
        do {
            try context.save()
            
            // Also save to CSV as backup
            saveToCSV(completion: completion)
        } catch {
            completion(.failure(DiaryError.saveFailed))
        }
    }
    
    func updateDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        // Update in CoreData
        let fetchRequest: NSFetchRequest<CDDiaryEntry> = CDDiaryEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %lld", diary.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let cdDiary = results.first {
                cdDiary.date = diary.date
                cdDiary.content = diary.content
                cdDiary.category = diary.category
                cdDiary.tags = diary.tags.joined(separator: ";")
                
                try context.save()
                
                // Also update CSV backup
                saveToCSV(completion: completion)
            } else {
                // If not found, create new
                saveDiary(diary, completion: completion)
            }
        } catch {
            completion(.failure(DiaryError.saveFailed))
        }
    }
    
    func deleteDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        // Delete from CoreData
        let fetchRequest: NSFetchRequest<CDDiaryEntry> = CDDiaryEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %lld", diary.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let cdDiary = results.first {
                context.delete(cdDiary)
                try context.save()
                
                // Also update CSV backup
                saveToCSV(completion: completion)
            } else {
                completion(.success(()))
            }
        } catch {
            completion(.failure(DiaryError.deleteFailed))
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
        
        // Clear existing data
        clearAllData()
        
        // Save all imported diaries to CoreData
        for diary in diaries {
            let cdDiary = CDDiaryEntry(context: context)
            cdDiary.id = diary.id
            cdDiary.date = diary.date
            cdDiary.content = diary.content
            cdDiary.category = diary.category
            cdDiary.tags = diary.tags.joined(separator: ";")
        }
        
        do {
            try context.save()
            
            // Also save to CSV file
            try csvString.write(to: csvFileURL, atomically: true, encoding: .utf8)
            
            completion(.success(diaries))
        } catch {
            completion(.failure(DiaryError.saveFailed))
        }
    }
    
    // MARK: - Private Methods
    
    /// Loads diaries from CSV file
    private func loadFromCSV(completion: @escaping (Result<[DiaryEntry], Error>) -> Void) {
        do {
            if FileManager.default.fileExists(atPath: csvFileURL.path) {
                let csvString = try String(contentsOf: csvFileURL, encoding: .utf8)
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
                
                // Import to CoreData for future use
                for diary in diaries {
                    let cdDiary = CDDiaryEntry(context: context)
                    cdDiary.id = diary.id
                    cdDiary.date = diary.date
                    cdDiary.content = diary.content
                    cdDiary.category = diary.category
                    cdDiary.tags = diary.tags.joined(separator: ";")
                }
                
                try context.save()
                
                completion(.success(diaries))
            } else {
                // No file exists yet, return empty array
                completion(.success([]))
            }
        } catch {
            completion(.failure(DiaryError.loadFailed))
        }
    }
    
    /// Saves all diaries to CSV file
    private func saveToCSV(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            // Get all diaries from CoreData
            let fetchRequest: NSFetchRequest<CDDiaryEntry> = CDDiaryEntry.fetchRequest()
            let cdDiaries = try context.fetch(fetchRequest)
            
            // Convert to DiaryEntry models
            let diaries = cdDiaries.compactMap { cdDiary -> DiaryEntry? in
                guard let date = cdDiary.date,
                      let content = cdDiary.content,
                      let category = cdDiary.category else {
                    return nil
                }
                
                let tags = cdDiary.tags?.components(separatedBy: ";") ?? []
                return DiaryEntry(
                    id: cdDiary.id,
                    date: date,
                    content: content,
                    category: category,
                    tags: tags
                )
            }
            
            // Generate CSV
            let csvString = exportToCSV(diaries: diaries)
            
            // Save to file
            try csvString.write(to: csvFileURL, atomically: true, encoding: .utf8)
            
            // Create backup
            createBackup(csvString: csvString)
            
            completion(.success(()))
        } catch {
            completion(.failure(DiaryError.saveFailed))
        }
    }
    
    /// Creates a backup of the CSV file
    private func createBackup(csvString: String) {
        let backupDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("backups")
        
        let dateFormatter = ISO8601DateFormatter()
        let timestamp = dateFormatter.string(from: Date())
        let backupURL = backupDirectory.appendingPathComponent("diaries-\(timestamp).csv")
        
        do {
            try csvString.write(to: backupURL, atomically: true, encoding: .utf8)
            
            // Limit number of backups (keep last 10)
            limitBackups()
        } catch {
            print("Failed to create backup: \(error.localizedDescription)")
        }
    }
    
    /// Creates backup directory if it doesn't exist
    private func createBackupDirectoryIfNeeded() {
        let backupDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("backups")
        
        if !FileManager.default.fileExists(atPath: backupDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
            } catch {
                print("Failed to create backup directory: \(error.localizedDescription)")
            }
        }
    }
    
    /// Limits the number of backups to keep
    private func limitBackups(maxBackups: Int = 10) {
        let backupDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("backups")
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            let sortedFiles = try fileURLs.sorted { 
                let date1 = try $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let date2 = try $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                return date1 > date2
            }
            
            // Remove older backups beyond the limit
            if sortedFiles.count > maxBackups {
                for i in maxBackups..<sortedFiles.count {
                    try FileManager.default.removeItem(at: sortedFiles[i])
                }
            }
        } catch {
            print("Failed to limit backups: \(error.localizedDescription)")
        }
    }
    
    /// Clears all data from CoreData
    private func clearAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDDiaryEntry.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentContainer.persistentStoreCoordinator.execute(batchDeleteRequest, with: context)
        } catch {
            print("Failed to clear data: \(error.localizedDescription)")
        }
    }
}

// MARK: - CoreData Model Class

/// CoreData entity for diary entries
@objc(CDDiaryEntry)
class CDDiaryEntry: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var date: Date?
    @NSManaged var content: String?
    @NSManaged var category: String?
    @NSManaged var tags: String?
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDDiaryEntry> {
        return NSFetchRequest<CDDiaryEntry>(entityName: "CDDiaryEntry")
    }
}