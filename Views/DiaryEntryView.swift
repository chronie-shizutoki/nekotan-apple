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
    
    /// State for animation settings
    @AppStorage("enableAnimations") private var enableAnimations = true
    
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
                // Content section with cute design
                Section(header: Text("内容").font(.kleeOne(size: 18))) {
                    // Check if animations are enabled
                    if enableAnimations {
                        AnimatedTextEditor(
                            title: "今日の気持ちを書いてね～♡",
                            text: $diary.content,
                            animationType: .glow,
                            color: Color.purple
                        )
                        .frame(minHeight: 150)
                        .kawaiiBorder(colors: [Color.pink, Color.purple], width: 2, cornerRadius: 10)
                    } else {
                        TextEditor(text: $diary.content)
                            .frame(minHeight: 150)
                    }
                    
                    HStack {
                        Spacer()
                        Text("\(diary.content.count) 文字")
                            .font(.kleeOne(size: 12))
                            .foregroundColor(Color.purple)
                    }
                }
                
                // Category section
                Section(header: Text("カテゴリー").font(.kleeOne(size: 18))) {
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(Color.pink)
                            Text("カテゴリーを選択")
                                .font(.kleeOne(size: 16))
                            Spacer()
                            Text(diary.category)
                                .font(.kleeOne(size: 16))
                                .foregroundColor(Color.purple)
                        }
                    }
                }
                
                // Tags section
                Section(header: Text("タグ").font(.kleeOne(size: 18))) {
                    // Current tags
                    ForEach(diary.tags, id: \.self) { tag in
                        HStack {
                            Text(tag)
                                .font(.kleeOne(size: 16))
                            Spacer()
                            Button(action: {
                                removeTag(tag)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.red)
                                    .bounceAnimation(strength: 0.5, duration: 0.3)
                            }
                        }
                    }
                    
                    // Add new tag
                    HStack {
                        // Check if animations are enabled
                        if enableAnimations {
                            // Use animated text field for tag input
                            AnimatedTextField(
                                title: "タグを追加",
                                text: $newTag,
                                animationType: .border,
                                color: Color.blue
                            )
                        } else {
                            TextField("タグを追加", text: $newTag)
                        }
                        
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color.green)
                                .floatAnimation(amplitude: 3, frequency: 2)
                        }
                        .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // Suggested tags
                    if !viewModel.tags.isEmpty {
                        Text("おすすめタグ")
                            .font(.kleeOne(size: 14))
                            .foregroundColor(Color.purple)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.tags.prefix(10)) { tag in
                                    Button(action: {
                                        if !diary.tags.contains(tag.name) {
                                            diary.tags.append(tag.name)
                                        }
                                    }) {
                                        Text(tag.name)
                                            .font(.kleeOne(size: 14))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.pink.opacity(0.2))
                                            .cornerRadius(8)
                                            .bounceAnimation(strength: 0.5, duration: 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(isNewDiary ? "新しい日記" : "日記を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(Color.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveDiary()
                    }
                    .foregroundColor(Color.pink)
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
    
    /// Category picker view with cute design
    private var categoryPickerView: some View {
        NavigationView {
            List {
                // Default categories
                Section(header: Text("デフォルトカテゴリー").font(.kleeOne(size: 18))) {
                    ForEach(DiaryEntry.defaultCategories, id: \.self) { category in
                        Button(action: {
                            diary.category = category
                            showingCategoryPicker = false
                        }) {
                            HStack {
                                Text(category)
                                    .font(.kleeOne(size: 16))
                                Spacer()
                                if diary.category == category {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color.pink)
                                }
                            }
                        }
                    }
                }
                
                // Custom category input
                Section(header: Text("カスタムカテゴリー").font(.kleeOne(size: 18))) {
                    TextField("カテゴリーを入力", text: $diary.category)
                        .font(.kleeOne(size: 16))
                        .onSubmit {
                            showingCategoryPicker = false
                        }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("カテゴリーを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        showingCategoryPicker = false
                    }
                    .foregroundColor(Color.pink)
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