//
//  DiaryEntryView.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI

/// View for creating or editing a diary entry
struct DiaryEntryView: View {
    // MARK: - Properties
    
    /// View model for diary operations
    @ObservedObject var viewModel: DiaryViewModel
    
    /// Flag indicating if this is a new diary entry
    let isNewDiary: Bool
    
    /// Environment to dismiss the view
    @Environment(\.dismiss) private var dismiss
    
    /// Local diary entry for editing
    @State private var diary: DiaryEntry
    
    /// State for showing category picker
    @State private var showingCategoryPicker = false
    
    /// State for new tag input
    @State private var newTag = ""
    
    /// State for showing alert
    @State private var showingAlert = false
    
    /// Alert message
    @State private var alertMessage = ""
    
    /// Alert title
    @State private var alertTitle = ""
    
    // MARK: - Initialization
    
    init(viewModel: DiaryViewModel, isNewDiary: Bool, diary: DiaryEntry? = nil) {
        self.viewModel = viewModel
        self.isNewDiary = isNewDiary
        
        if isNewDiary {
            // Use the newDiary from viewModel for new entries
            _diary = State(initialValue: viewModel.newDiary)
        } else if let diary = diary {
            // Use the provided diary for editing
            _diary = State(initialValue: diary)
        } else if let selectedDiary = viewModel.selectedDiary {
            // Use the selected diary from viewModel
            _diary = State(initialValue: selectedDiary)
        } else {
            // Fallback to a new diary
            _diary = State(initialValue: DiaryEntry(content: ""))
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // Content section
                Section(header: Text("Content")) {
                    // Check if animations are enabled
                    if let enableAnimations = UserDefaults.standard.object(forKey: "enableAnimations") as? Bool, enableAnimations {
                        AnimatedTextEditor(
                            title: "Write your thoughts...",
                            text: $diary.content,
                            animationType: .glow,
                            color: .purple
                        )
                        .frame(minHeight: 150)
                    } else {
                        TextEditor(text: $diary.content)
                            .frame(minHeight: 150)
                    }
                    
                    HStack {
                        Spacer()
                        Text("\(diary.content.count) characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Category section
                Section(header: Text("Category")) {
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            Text("Category")
                            Spacer()
                            Text(diary.category)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Tags section
                Section(header: Text("Tags")) {
                    // Current tags
                    ForEach(diary.tags, id: \.self) { tag in
                        HStack {
                            Text(tag)
                            Spacer()
                            Button(action: {
                                removeTag(tag)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Add new tag
                    HStack {
                        // Check if animations are enabled
                        if let enableAnimations = UserDefaults.standard.object(forKey: "enableAnimations") as? Bool, enableAnimations {
                            // Use animated text field for tag input
                            AnimatedTextField(
                                title: "Add tag",
                                text: $newTag,
                                animationType: .border,
                                color: .blue
                            )
                        } else {
                            TextField("Add tag", text: $newTag)
                        }
                        
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // Suggested tags
                    if !viewModel.tags.isEmpty {
                        Text("Suggested Tags")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.tags.prefix(10)) { tag in
                                    Button(action: {
                                        if !diary.tags.contains(tag.name) {
                                            diary.tags.append(tag.name)
                                        }
                                    }) {
                                        Text(tag.name)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.secondary.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(isNewDiary ? "New Diary" : "Edit Diary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveDiary()
                    }
                    .disabled(diary.isEmpty)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                categoryPickerView
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Category picker view
    private var categoryPickerView: some View {
        NavigationView {
            List {
                // Default categories
                Section(header: Text("Default Categories")) {
                    ForEach(DiaryEntry.defaultCategories, id: \.self) { category in
                        Button(action: {
                            diary.category = category
                            showingCategoryPicker = false
                        }) {
                            HStack {
                                Text(category)
                                Spacer()
                                if diary.category == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
                
                // Custom category input
                Section(header: Text("Custom Category")) {
                    TextField("Enter category", text: $diary.category)
                        .onSubmit {
                            showingCategoryPicker = false
                        }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingCategoryPicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    /// Adds a new tag
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !diary.tags.contains(trimmedTag) {
            diary.tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    /// Removes a tag
    /// - Parameter tag: Tag to remove
    private func removeTag(_ tag: String) {
        diary.tags.removeAll { $0 == tag }
    }
    
    /// Saves the diary entry
    private func saveDiary() {
        if isNewDiary {
            // Update the viewModel's newDiary
            viewModel.newDiary = diary
            
            // Save the new diary
            viewModel.saveDiary { result in
                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    alertTitle = "Error"
                    alertMessage = "Failed to save diary: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        } else {
            // Update existing diary
            viewModel.updateDiary(diary) { result in
                switch result {
                case .success:
                    // Update selected diary if it's the same one
                    if viewModel.selectedDiary?.id == diary.id {
                        viewModel.selectedDiary = diary
                    }
                    dismiss()
                case .failure(let error):
                    alertTitle = "Error"
                    alertMessage = "Failed to update diary: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Preview

struct DiaryEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryEntryView(viewModel: DiaryViewModel(), isNewDiary: true)
    }
}