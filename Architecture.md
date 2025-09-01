# NekoTan - Swift Application Architecture Design

## 1. Application Architecture

We will adopt the MVVM (Model-View-ViewModel) architecture pattern, which is recommended by Apple and particularly well-suited for SwiftUI applications.

```
+-------------------+      +--------------------+      +-------------------+
|                   |      |                    |      |                   |
|       Model       |<---->|     ViewModel      |<---->|       View        |
|                   |      |                    |      |                   |
+-------------------+      +--------------------+      +-------------------+
         ^                          ^                          ^
         |                          |                          |
         v                          v                          v
+-------------------+      +--------------------+      +-------------------+
|                   |      |                    |      |                   |
|   Data Services   |<---->|  Business Logic    |<---->|    UI Controls    |
|                   |      |                    |      |                   |
+-------------------+      +--------------------+      +-------------------+
```

### 1.1 Layer Structure

- **Model Layer**: Defines data structures and business entities
- **ViewModel Layer**: Handles business logic and state management
- **View Layer**: Responsible for UI presentation and user interaction
- **Services Layer**: Handles data persistence, network requests, etc.

## 2. Data Models

### 2.1 Core Data Models

#### DiaryEntry

```swift
struct DiaryEntry: Identifiable, Codable {
    var id: Int64
    var date: Date
    var content: String
    var category: String
    var tags: [String]
    
    // Computed Properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
```

#### Category

```swift
struct Category: Identifiable, Codable, Hashable {
    var id: String { name }
    var name: String
    var count: Int = 0
}
```

#### Tag

```swift
struct Tag: Identifiable, Codable, Hashable {
    var id: String { name }
    var name: String
    var count: Int = 0
}
```

## 3. View Models

### 3.1 DiaryViewModel

```swift
class DiaryViewModel: ObservableObject {
    @Published var diaries: [DiaryEntry] = []
    @Published var filteredDiaries: [DiaryEntry] = []
    @Published var categories: [Category] = []
    @Published var tags: [Tag] = []
    @Published var selectedCategory: String? = nil
    @Published var selectedTags: [String] = []
    @Published var searchText: String = ""
    
    // Pagination
    @Published var currentPage: Int = 1
    let pageSize: Int = 5
    
    // Data Services
    private let dataService: DiaryDataService
    
    init(dataService: DiaryDataService) {
        self.dataService = dataService
        loadDiaries()
    }
    
    // Load Diaries
    func loadDiaries() {
        // Load diaries from data service
    }
    
    // Save Diary
    func saveDiary(content: String, category: String, tags: [String]) {
        // Save diary to data service
    }
    
    // Delete Diary
    func deleteDiary(id: Int64) {
        // Delete diary from data service
    }
    
    // Update Diary
    func updateDiary(id: Int64, content: String, category: String, tags: [String]) {
        // Update diary in data service
    }
    
    // Search and Filter
    func filterDiaries() {
        // Filter diaries based on search text, selected category, and tags
    }
    
    // Pagination
    func nextPage() {
        // Next Page
    }
    
    func previousPage() {
        // Previous Page
    }
    
    func goToPage(_ page: Int) {
        // Go to specified page
    }
    
    // Get Diaries for Current Page
    func getCurrentPageDiaries() -> [DiaryEntry] {
        // Return diaries for current page
        return []
    }
    
    // Get Total Page Count
    func getPageCount() -> Int {
        // Calculate total page count
        return 0
    }
}
```

## 4. Data Services

### 4.1 DiaryDataService

```swift
protocol DiaryDataService {
    func loadDiaries() -> [DiaryEntry]
    func saveDiary(_ diary: DiaryEntry) -> Bool
    func updateDiary(_ diary: DiaryEntry) -> Bool
    func deleteDiary(id: Int64) -> Bool
    func exportToCSV() -> String
    func importFromCSV(_ csv: String) -> Bool
    func exportToJSON() -> Data?
    func importFromJSON(_ json: Data) -> Bool
}
```

### 4.2 CoreDataDiaryService

```swift
class CoreDataDiaryService: DiaryDataService {
    private let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "NekoTanDiary")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data加载失败: \(error.localizedDescription)")
            }
        }
    }
    
    // Implementation of DiaryDataService protocol methods
}
```

## 5. User Interface

### 5.1 Main Views

- **MainView**: The main view of the application, containing a TabView
- **DiaryListView**: The view to display the list of diaries
- **DiaryEditorView**: The view to edit a diary entry
- **DiaryDetailView**: The view to display the details of a diary entry
- **SettingsView**: The view to manage application settings

### 5.2 Components

- **TagView**: The component to display and select tags
- **CategoryPickerView**: The component to select a category
- **SearchBarView**: The component to search for diaries
- **PaginationView**: The component to handle pagination
- **DiaryCardView**: The component to display a diary entry card

## 6. Data Persistence

We will use CoreData as the primary data persistence scheme, while also supporting CSV and JSON import/export functionality.

### 6.1 CoreData Model

- **DiaryEntryEntity**: Corresponds to DiaryEntry model
- **CategoryEntity**: Corresponds to Category model
- **TagEntity**: Corresponds to Tag model

## 7. Platform-Specific Features

### 7.1 iOS/iPadOS-Specific Features

- **Widget Support**: Create diary widgets using WidgetKit
- **Share Extension**: Support sharing content from other apps to diary
- **iCloud Sync**: Cross-device synchronization using CloudKit
- **Dark Mode**: iOS dark mode adaptation
- **Local Notifications**: Remind users to write diary entries

### 7.2 macOS-Specific Features

- **Menu Bar Widget**: Quick diary entry from menu bar
- **Keyboard Shortcuts**: Support for keyboard shortcut operations
- **Multi-window Support**: Support editing different diaries in multiple windows
- **Touch Bar Support**: Quick actions for Macs with Touch Bar

## 8. Security Considerations

- **Data Encryption**: Local encryption of sensitive data
- **Biometric Authentication**: Face ID/Touch ID protection for diaries
- **Backup Strategy**: Automatic backup and recovery mechanisms

## 9. Accessibility

- **VoiceOver Support**: Full VoiceOver screen reader support
- **Dynamic Type**: Support for dynamic font size adjustment
- **Reduced Motion**: Reduced animation options for users who need it

## 10. Internationalization and Localization

- **Multi-language Support**: Support for Japanese, English, Chinese and other languages
- **Localized Date Formats**: Display date formats according to user region settings
