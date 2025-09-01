//
//  DiaryRowView.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI

/// View for displaying a single diary entry in a list
struct DiaryRowView: View {
    // MARK: - Properties
    
    /// The diary entry to display
    let diary: DiaryEntry
    
    /// Action to perform when the row is tapped
    let onTap: () -> Void
    
    /// Action to perform when the edit button is tapped
    let onEdit: () -> Void
    
    /// Action to perform when the delete button is tapped
    let onDelete: () -> Void
    
    /// State for animation settings
    @AppStorage("enableAnimations") private var enableAnimations = true
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header with date and category
                HStack {
                    VStack(alignment: .leading) {
                        Text(formattedDate)
                            .font(.kleeOne(size: 16))
                            .foregroundColor(Color.pink)
                        Text(diary.category)
                            .font(.kleeOne(size: 14))
                            .foregroundColor(Color.purple)
                    }
                    Spacer()
                    // Category icon with animation
                    Image(systemName: categoryIcon)
                        .foregroundColor(categoryColor)
                        .floatAnimation(amplitude: 5, frequency: 2)
                }
                
                // Content preview
                Text(contentPreview)
                    .font(.kleeOne(size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                // Tags row
                if !diary.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(diary.tags.prefix(3), id: \.self) {
                                Text("#\($0)")
                                    .font(.kleeOne(size: 12))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.pink.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            if diary.tags.count > 3 {
                                Text("+\(diary.tags.count - 3) more")
                                    .font(.kleeOne(size: 12))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .kawaiiBorder(colors: [Color.pink, Color.purple], width: 1, cornerRadius: 12)
            .shadow(radius: 4, y: 2)
            .contextMenu {
                Button(action: onEdit) {
                    Label("編集", systemImage: "pencil")
                }
                Button(action: onDelete) {
                    Label("削除", systemImage: "trash")
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .bounceAnimation(strength: 0.5, duration: 0.3)
    }
    
    // MARK: - Helper properties
    
    /// Formatted date string
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: diary.date)
    }
    
    /// Preview of diary content
    private var contentPreview: String {
        if diary.content.isEmpty {
            return "(空の日記)"
        }
        return diary.content
    }
    
    /// Icon for the diary category
    private var categoryIcon: String {
        switch diary.category {
        case "未分類": return "folder.fill"
        case "日常": return "house.fill"
        case "仕事": return "briefcase.fill"
        case "勉強": return "book.fill"
        case "趣味": return "gamecontroller.fill"
        case "思考": return "brain.fill"
        case "旅行": return "airplane.fill"
        case "健康": return "heart.fill"
        case "創作": return "paintbrush.fill"
        case "読書": return "book.closed.fill"
        case "料理": return "food.fill"
        case "夢": return "moon.stars.fill"
        case "目標": return "target.fill"
        case "映画": return "film.fill"
        case "ゲーム": return "gamecontroller.fill"
        case "音楽": return "music.note.fill"
        default: return "folder.fill"
        }
    }
    
    /// Color for the diary category icon
    private var categoryColor: Color {
        switch diary.category {
        case "未分類": return .gray
        case "日常": return .blue
        case "仕事": return .indigo
        case "勉強": return .green
        case "趣味": return .purple
        case "思考": return .amber
        case "旅行": return .orange
        case "健康": return .red
        case "創作": return .pink
        case "読書": return .brown
        case "料理": return .yellow
        case "夢": return .violet
        case "目標": return .teal
        case "映画": return .cyan
        case "ゲーム": return .mint
        case "音楽": return .indigo
        default: return .gray
        }
    }
}