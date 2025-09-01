//
//  DiaryListView.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI

/// View for displaying the list of diary entries
struct DiaryListView: View {
    // MARK: - Properties
    
    /// View model for diary operations
    @ObservedObject var viewModel: DiaryViewModel
    
    /// State for showing the new diary entry sheet
    @State private var showingNewDiarySheet = false
    
    /// State for showing the export/import options
    @State private var showingExportImportOptions = false
    
    /// State for showing the import dialog
    @State private var showingImportDialog = false
    
    /// State for the import text
    @State private var importText = ""
    
    /// State for showing alert
    @State private var showingAlert = false
    
    /// Alert message
    @State private var alertMessage = ""
    
    /// Alert title
    @State private var alertTitle = ""
    
    /// State for animation settings
    @AppStorage("enableAnimations") private var enableAnimations = true
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                searchAndFilterBar
                
                // Diary list
                if viewModel.filteredDiaries.isEmpty {
                    // Empty state view with cute design
                    emptyStateView
                } else {
                    List {
                        ForEach(viewModel.filteredDiaries) { diary in
                            DiaryRowView(diary: diary)
                                .contextMenu {
                                    Button(action: {
                                        viewModel.selectedDiary = diary
                                        // Open edit view
                                    }) {
                                        Label("編集", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        deleteDiary(diary)
                                    }) {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .wavyBackground()
                }
            }
            .navigationTitle("ネコタンの日記")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingExportImportOptions = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color.purple)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewDiarySheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.pink)
                            .floatAnimation(amplitude: 5, frequency: 3)
                    }
                }
            }
            .sheet(isPresented: $showingNewDiarySheet) {
                DiaryEntryView(viewModel: viewModel, isNewDiary: true)
            }
            .sheet(isPresented: $showingExportImportOptions) {
                exportImportView
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    // MARK: - Subviews
    
    /// Search and filter bar view with cute design
    private var searchAndFilterBar: some View {
        VStack(spacing: 8) {
            // Search field with cute animation
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.pink)
                    .floatAnimation(amplitude: 3, frequency: 2)
                
                // Check if animations are enabled
                if enableAnimations {
                    // Use animated text field for search
                    AnimatedTextField(
                        title: "日記を検索...",
                        text: $viewModel.searchQuery,
                        animationType: .glow,
                        color: Color.pink
                    )
                } else {
                    TextField("日記を検索...", text: $viewModel.searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.pink)
                            .bounceAnimation(strength: 0.5, duration: 0.3)
                    }
                }
            }
            .padding(.horizontal)
            
            // Category and tag filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All categories button
                    categoryFilterButton("All")
                    
                    // Category buttons
                    ForEach(viewModel.categories) { category in
                        categoryFilterButton(category.name)
                    }
                }
                .padding(.horizontal)
            }
            
            // Tag filters if a category is selected
            if !viewModel.selectedCategory.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // All tags button
                        tagFilterButton("All")
                        
                        // Tag buttons for selected category
                        ForEach(viewModel.tags.filter { tag in
                            viewModel.diaries.contains { diary in
                                diary.category == viewModel.selectedCategory && diary.tags.contains(tag.name)
                            }
                        }) { tag in
                            tagFilterButton(tag.name)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    /// Export/Import view
    private var exportImportView: some View {
        NavigationView {
            List {
                Section(header: Text("Export")) {
                    Button(action: exportCSV) {
                        Label("Export as CSV", systemImage: "arrow.up.doc")
                    }
                }
                
                Section(header: Text("Import")) {
                    Button(action: { showingImportDialog = true }) {
                        Label("Import from CSV", systemImage: "arrow.down.doc")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Export/Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingExportImportOptions = false
                    }
                }
            }
            .sheet(isPresented: $showingImportDialog) {
                NavigationView {
                    VStack {
                        TextEditor(text: $importText)
                            .padding()
                            .border(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text("Paste CSV content here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .navigationTitle("Import CSV")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingImportDialog = false
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Import") {
                                importCSV(importText)
                                showingImportDialog = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Creates a category filter button
    /// - Parameter category: Category name
    /// - Returns: Button view
    private func categoryFilterButton(_ category: String) -> some View {
        Button(action: {
            if category == "All" {
                viewModel.selectedCategory = ""
            } else {
                viewModel.selectedCategory = category
            }
            viewModel.selectedTag = ""
        }) {
            Text(category)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    (category == "All" && viewModel.selectedCategory.isEmpty) ||
                    category == viewModel.selectedCategory
                    ? Color.accentColor
                    : Color.secondary.opacity(0.2)
                )
                .foregroundColor(
                    (category == "All" && viewModel.selectedCategory.isEmpty) ||
                    category == viewModel.selectedCategory
                    ? Color.white
                    : Color.primary
                )
                .cornerRadius(16)
        }
    }
    
    /// Creates a tag filter button
    /// - Parameter tag: Tag name
    /// - Returns: Button view
    private func tagFilterButton(_ tag: String) -> some View {
        Button(action: {
            if tag == "All" {
                viewModel.selectedTag = ""
            } else {
                viewModel.selectedTag = tag
            }
        }) {
            Text(tag)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    (tag == "All" && viewModel.selectedTag.isEmpty) ||
                    tag == viewModel.selectedTag
                    ? Color.accentColor
                    : Color.secondary.opacity(0.2)
                )
                .foregroundColor(
                    (tag == "All" && viewModel.selectedTag.isEmpty) ||
                    tag == viewModel.selectedTag
                    ? Color.white
                    : Color.primary
                )
                .cornerRadius(16)
        }
    }
    
    // MARK: - Methods
    
    /// Deletes a diary entry
    /// - Parameter diary: The diary entry to delete
    private func deleteDiary(_ diary: DiaryEntry) {
        viewModel.deleteDiary(diary) { result in
            switch result {
            case .success:
                // Successfully deleted
                break
            case .failure(let error):
                alertTitle = "Error"
                alertMessage = "Failed to delete diary: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    /// Exports diaries to CSV
    private func exportCSV() {
        let csvString = viewModel.exportToCSV()
        
        // In a real app, we would use UIActivityViewController or similar
        // to share the CSV file. For now, we'll just show a success message.
        UIPasteboard.general.string = csvString
        
        alertTitle = "Export Successful"
        alertMessage = "CSV data has been copied to clipboard"
        showingAlert = true
        
        showingExportImportOptions = false
    }
    
    /// Imports diaries from CSV
    /// - Parameter csvString: CSV string to import
    private func importCSV(_ csvString: String) {
        viewModel.importFromCSV(csvString) { result in
            switch result {
            case .success:
                alertTitle = "Import Successful"
                alertMessage = "Diaries have been imported"
            case .failure(let error):
                alertTitle = "Import Failed"
                alertMessage = error.localizedDescription
            }
            showingAlert = true
        }
    }
}

// MARK: - DiaryRowView

/// View for a single diary row in the list
struct DiaryRowView: View {
    let diary: DiaryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(diary.shortDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(diary.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(diary.content)
                .lineLimit(3)
                .font(.body)
            
            if !diary.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(diary.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct DiaryListView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryListView(viewModel: DiaryViewModel())
    }
}