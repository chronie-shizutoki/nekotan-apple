//
//  DiaryDataManager.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import Foundation
import CoreData

// Import shared error types
import DiaryError

/// Implementation of DiaryDataService using CoreData and file-based storage with improved thread safety
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
        
        // Configure persistent container for thread safety
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = nil
        
        return container
    }()

    /// Main thread CoreData managed object context for UI operations
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Initialization

    init() {
        // Setup initial data if needed
        createBackupDirectoryIfNeeded()
    }

    // MARK: - DiaryDataService Implementation

    func loadDiaries(completion: @escaping (Result<[DiaryEntry], Error>) -> Void) {
        // Create a background task for loading data
        persistentContainer.performBackgroundTask { [weak self] (backgroundContext) in
            guard let self = self else { 
                completion(.failure(DiaryError.loadFailed))
                return 
            }
            
            // First try to load from CoreData
            do {
                let fetchRequest: NSFetchRequest<CDDiaryEntry> = CDDiaryEntry.fetchRequest()
                let cdDiaries = try backgroundContext.fetch(fetchRequest)

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
                    
                    // Return results on main thread
                    DispatchQueue.main.async {
                        completion(.success(diaries))
                    }
                    return
                }
            } catch {
                print("Error loading from CoreData: \(error.localizedDescription)")
                // Continue to try CSV as fallback
            }

            // Fallback to CSV file if CoreData is empty or fails
            self.loadFromCSV(completion: completion)
        }
    }

    func saveDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        // Use background context for saving to avoid blocking UI
        persistentContainer.performBackgroundTask { [weak self] (backgroundContext) in
            guard let self = self else { 
                completion(.failure(DiaryError.saveFailed))
                return 
            }
            
            // Save to CoreData
            let cdDiary = CDDiaryEntry(context: backgroundContext)
            cdDiary.id = diary.id
            cdDiary.date = diary.date
            cdDiary.content = diary.content
            cdDiary.category = diary.category
            cdDiary.tags = diary.tags.joined(separator: ";")

            do {
                try backgroundContext.save()
                
                // Also save to CSV as backup
                self.saveToCSV(completion: completion)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(DiaryError.saveFailed))
                }
            }
        }
    }

    func updateDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        // Use background context for updating to avoid blocking UI
        persistentContainer.performBackgroundTask { [weak self] (backgroundContext) in
            guard let self = self else { 
                completion(.failure(DiaryError.saveFailed))
                return 
            }
            
            // Update in CoreData
            let fetchRequest: NSFetchRequest<CDDiaryEntry> = CDDiaryEntry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %lld", diary.id)

            do {
                let results = try backgroundContext.fetch(fetchRequest)
                if let cdDiary = results.first {
                    cdDiary.date = diary.date
                    cdDiary.content = diary.content
                    cdDiary.category = diary.category
                    cdDiary.tags = diary.tags.joined(separator: ";")

                    try backgroundContext.save()

                    // Also update CSV backup
                    self.saveToCSV(completion: completion)
                } else {
                    // If not found, create new
                    self.saveDiary(diary, completion: completion)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(DiaryError.saveFailed))
                }
            }
        }
    }

    func deleteDiary(_ diary: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        // Use background context for deletion to avoid blocking UI
        persistentContainer.performBackgroundTask { [weak self] (backgroundContext) in
            guard let self = self else { 
                completion(.failure(DiaryError.deleteFailed))
                return 
            }
            
            // Delete from CoreData
            let fetchRequest: NSFetchRequest<CDDiaryEntry> = CDDiaryEntry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %lld", diary.id)

            do {
                let results = try backgroundContext.fetch(fetchRequest)
                if let cdDiary = results.first {
                    backgroundContext.delete(cdDiary)
                    try backgroundContext.save()

                    // Also update CSV backup
                    self.saveToCSV(completion: completion)
                } else {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(DiaryError.deleteFailed))
                }
            }
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
        // Parse CSV on a background queue
        DispatchQueue.global(qos: .background).async {
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
            
            // Use background context for importing to avoid blocking UI
            self.persistentContainer.performBackgroundTask { [weak self] (backgroundContext) in
                guard let self = self else { 
                    completion(.failure(DiaryError.saveFailed))
                    return 
                }
                
                // Clear existing data
                self.clearAllData(in: backgroundContext)

                // Save all imported diaries to CoreData
                for diary in diaries {
                    let cdDiary = CDDiaryEntry(context: backgroundContext)
                    cdDiary.id = diary.id
                    cdDiary.date = diary.date
                    cdDiary.content = diary.content
                    cdDiary.category = diary.category
                    cdDiary.tags = diary.tags.joined(separator: ";")
                }

                do {
                    try backgroundContext.save()

                    // Also save to CSV file on main queue for file operations
                    DispatchQueue.main.async {
                        do {
                            try csvString.write(to: self.csvFileURL, atomically: true, encoding: .utf8)
                            completion(.success(diaries))
                        } catch {
                            completion(.failure(DiaryError.saveFailed))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(DiaryError.saveFailed))
                    }
                }
            }
        }
    }

    // MARK: - Private Methods

    /// Loads diaries from CSV file
    private func loadFromCSV(completion: @escaping (Result<[DiaryEntry], Error>) -> Void) {
        // Perform file operations on a background queue
        DispatchQueue.global(qos: .background).async {
            do {
                if FileManager.default.fileExists(atPath: self.csvFileURL.path) {
                    let csvString = try String(contentsOf: self.csvFileURL, encoding: .utf8)
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

                    // Import to CoreData for future use using background context
                    self.persistentContainer.performBackgroundTask { (backgroundContext) in
                        do {
                            for diary in diaries {
                                let cdDiary = CDDiaryEntry(context: backgroundContext)
                                cdDiary.id = diary.id
                                cdDiary.date = diary.date
                                cdDiary.content = diary.content
                                cdDiary.category = diary.category
                                cdDiary.tags = diary.tags.joined(separator: ";")
                            }

                            try backgroundContext.save()

                            // Return results on main thread
                            DispatchQueue.main.async {
                                completion(.success(diaries))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(DiaryError.saveFailed))
                            }
                        }
                    }
                } else {
                    // No file exists yet, return empty array
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(DiaryError.loadFailed))
                }
            }
        }
    }

    /// Saves all diaries to CSV file
    private func saveToCSV(completion: @escaping (Result<Void, Error>) -> Void) {
        // Perform CSV generation and file operations on a background queue
        DispatchQueue.global(qos: .background).async {
            do {
                // Use view context for fetching since we're just reading data
                let fetchRequest: NSFetchRequest<CDDiaryEntry> = CDDiaryEntry.fetchRequest()
                
                var cdDiaries: [CDDiaryEntry] = []
                do {
                    // Perform fetch on view context (main thread)
                    try DispatchQueue.main.sync {
                        cdDiaries = try self.viewContext.fetch(fetchRequest)
                    }
                } catch {
                    throw DiaryError.loadFailed
                }

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
                let csvString = self.exportToCSV(diaries: diaries)

                // Save to file (main thread for file operations)
                try DispatchQueue.main.sync {
                    try csvString.write(to: self.csvFileURL, atomically: true, encoding: .utf8)
                }

                // Create backup
                self.createBackup(csvString: csvString)

                // Return success on main thread
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(DiaryError.saveFailed))
                }
            }
        }
    }

    /// Creates a backup of the CSV file
    private func createBackup(csvString: String) {
        DispatchQueue.global(qos: .background).async {
            let backupDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("backups")

            let dateFormatter = ISO8601DateFormatter()
            let timestamp = dateFormatter.string(from: Date())
            let backupURL = backupDirectory.appendingPathComponent("diaries-\(timestamp).csv")

            do {
                try csvString.write(to: backupURL, atomically: true, encoding: .utf8)

                // Limit number of backups (keep last 10)
                self.limitBackups()
            } catch {
                print("Failed to create backup: \(error.localizedDescription)")
            }
        }
    }

    /// Creates backup directory if it doesn't exist
    private func createBackupDirectoryIfNeeded() {
        // Perform file operations on main thread
        DispatchQueue.main.async {
            let backupDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("backups")

            if !FileManager.default.fileExists(atPath: backupDirectory.path) {
                do {
                    try FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
                } catch {
                    print("Failed to create backup directory: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Limits the number of backups to keep
    private func limitBackups(maxBackups: Int = 10) {
        DispatchQueue.global(qos: .background).async {
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
    }

    /// Clears all data from CoreData using the provided context
    private func clearAllData(in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDDiaryEntry.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // Configure batch delete to return object IDs for updating the context
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        do {
            if let deleteResult = try persistentContainer.persistentStoreCoordinator.execute(batchDeleteRequest, with: context) as? NSBatchDeleteResult,
               let objectIDArray = deleteResult.result as? [NSManagedObjectID] {
                
                // Create a changes object to merge the batch delete changes into the context
                let changes = [NSDeletedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            }
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