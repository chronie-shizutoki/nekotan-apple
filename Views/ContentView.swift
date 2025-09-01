//
//  ContentView.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI
import UIKit
import CustomCharts
import SettingsView

/// Main content view of the application
struct ContentView: View {
    // MARK: - Cherry Blossom Animation
    @State private var petals: [CherryBlossom] = []
    @State private var timer: Timer? = nil
    // MARK: - Properties
    
    /// Shared diary view model
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    
    /// State for selected tab
    @State private var selectedTab = 0
    
    /// State for animation settings
    @AppStorage("enableAnimations") private var enableAnimations = true
    
    /// State for cute color theme
    @AppStorage("themeColor") private var themeColor = 0 // 0: pink, 1: purple, 2: blue, 3: yellow
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    themeColors[themeColor].opacity(0.1), 
                    themeColors[themeColor].opacity(0.3)
                ]), 
                startPoint: .top, 
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Main content with cute border
            VStack {
                TabView(selection: $selectedTab) {
                    // Diary list tab
                    DiaryListView(viewModel: diaryViewModel)
                        .tabItem {
                            Label("日記", systemImage: "book.fill")
                                .foregroundColor(themeColors[themeColor])
                        }
                        .tag(0)
                    
                    // Statistics tab
                    StatisticsView(viewModel: diaryViewModel)
                        .tabItem {
                            Label("統計", systemImage: "chart.bar.fill")
                                .foregroundColor(themeColors[themeColor])
                        }
                        .tag(1)
                    
                    // Settings Tab with cute animation
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                                .sparkleAnimation(frequency: 1.5)
                            Text("設定")
                        }
                        .tag(2)
                }
                .accentColor(themeColors[themeColor])
                .kawaiiBorder(colors: [themeColors[themeColor], themeColors[(themeColor + 1) % 4]], width: 3, cornerRadius: 20)
                .padding()
                .shadow(color: themeColors[themeColor].opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Floating notification
                if let notification = diaryViewModel.notification {
                    NotificationBanner(message: notification, color: themeColors[themeColor])
                        .floatAnimation(amplitude: 8, frequency: 4)
                }
            }
            
            // Apply sakura effect if animations are enabled
            if enableAnimations {
                Color.clear.sakuraEffect(petalCount: 30)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Theme colors array
    private var themeColors: [Color] {
        return [
            Color.pink,
            Color.purple,
            Color.blue,
            Color.yellow
        ]
    }
}

/// Notification banner view
struct NotificationBanner: View {
    /// The message to display
    let message: String
    
    /// The color of the banner
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: "heart.fill")
                .foregroundColor(.white)
                .padding(.trailing, 5)
            Text(message)
                .foregroundColor(.white)
                .font(.kleeOne(size: 14))
                .fontWeight(.bold)
        }
        .padding(10)
        .background(color)
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal, 20)
    }
}

// MARK: - StatisticsView

/// View for displaying diary statistics with cute design
struct StatisticsView: View {
    // MARK: - Properties
    
    /// Diary view model
    @ObservedObject var viewModel: DiaryViewModel
    
    /// State for animation settings
    @AppStorage("enableAnimations") private var enableAnimations = true
    
    /// Theme color
    @AppStorage("themeColor") private var themeColor = 0 // 0: pink, 1: purple, 2: blue, 3: yellow
    
    // MARK: - Theme colors
    
    private let themeColors = [
        Color.pink,
        Color.purple,
        Color.blue,
        Color.yellow
    ]
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    // Total entries with cute animation
                    Section {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(themeColors[themeColor])
                                    .floatAnimation(amplitude: 8, frequency: 2)
                                Text("総日記数")
                                    .font(.kleeOne(size: 18))
                                    .foregroundColor(themeColors[themeColor])
                                Text("\(viewModel.diaries.count)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(themeColors[themeColor])
                                    .bounceAnimation(strength: 0.3, duration: 1)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    
                    // Chart visualization section
                    Section(header: Text("ビジュアル統計").font(.kleeOne(size: 18)).foregroundColor(themeColors[themeColor])) {
                        // Category distribution pie chart
                        if !viewModel.prepareCategoryPieData().isEmpty {
                            KawaiiPieChart(
                                data: viewModel.prepareCategoryPieData(),
                                themeColor: themeColors[themeColor]
                            )
                        }
                        
                        // Monthly trend line chart
                        if !viewModel.prepareMonthlyTrendData().isEmpty {
                            KawaiiLineChart(
                                data: viewModel.prepareMonthlyTrendData(),
                                themeColor: themeColors[themeColor]
                            )
                        }
                        
                        // Category statistics bar chart
                        if !viewModel.prepareCategoryChartData().isEmpty {
                            KawaiiBarChart(
                                data: viewModel.prepareCategoryChartData(),
                                themeColor: themeColors[themeColor]
                            )
                        }
                    }
                    
                    // Category statistics with cute design
                    Section(header: Text("カテゴリー統計").font(.kleeOne(size: 18)).foregroundColor(themeColors[themeColor])) {
                        ForEach(viewModel.categories.filter { $0.count > 0 }.sorted(by: { $0.count > $1.count }).prefix(10)) { category in
                            HStack {
                                // Category icon
                                Image(systemName: categoryIcon(for: category.name))
                                    .foregroundColor(categoryColor(for: category.name))
                                Text(category.name)
                                    .font(.kleeOne(size: 16))
                                Spacer()
                                Text("\(category.count)")
                                    .font(.kleeOne(size: 14))
                                    .foregroundColor(themeColors[themeColor])
                            }
                            .kawaiiBorder(colors: [themeColors[themeColor], themeColors[(themeColor + 1) % 4]], width: 1, cornerRadius: 8)
                            .padding(4)
                        }
                    }
                    
                    // Tag statistics with cute design
                    Section(header: Text("タグ統計").font(.kleeOne(size: 18)).foregroundColor(themeColors[themeColor])) {
                        ForEach(viewModel.tags.filter { $0.count > 0 }.sorted(by: { $0.count > $1.count }).prefix(10)) { tag in
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(themeColors[(themeColor + 2) % 4])
                                Text(tag.name)
                                    .font(.kleeOne(size: 16))
                                Spacer()
                                Text("\(tag.count)")
                                    .font(.kleeOne(size: 14))
                                    .foregroundColor(themeColors[themeColor])
                            }
                            .kawaiiBorder(colors: [themeColors[(themeColor + 2) % 4], themeColors[(themeColor + 3) % 4]], width: 1, cornerRadius: 8)
                            .padding(4)
                        }
                    }
                    
                    // General statistics with cute design
                    Section(header: Text("基本統計").font(.kleeOne(size: 18)).foregroundColor(themeColors[themeColor])) {
                        if let oldestDate = viewModel.diaries.map({ $0.date }).min() {
                            HStack {
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(themeColors[themeColor])
                                Text("最初の日記")
                                    .font(.kleeOne(size: 16))
                                Spacer()
                                Text(formatDate(oldestDate))
                                    .font(.kleeOne(size: 14))
                                    .foregroundColor(themeColors[themeColor])
                            }
                            .kawaiiBorder(colors: [themeColors[themeColor], themeColors[(themeColor + 1) % 4]], width: 1, cornerRadius: 8)
                            .padding(4)
                        }
                        
                        if let newestDate = viewModel.diaries.map({ $0.date }).max() {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundColor(themeColors[themeColor])
                                Text("最新の日記")
                                    .font(.kleeOne(size: 16))
                                Spacer()
                                Text(formatDate(newestDate))
                                    .font(.kleeOne(size: 14))
                                    .foregroundColor(themeColors[themeColor])
                            }
                            .kawaiiBorder(colors: [themeColors[themeColor], themeColors[(themeColor + 1) % 4]], width: 1, cornerRadius: 8)
                            .padding(4)
                        }
                        
                        // Average entries per month
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(themeColors[themeColor])
                            Text("月間平均")
                                .font(.kleeOne(size: 16))
                            Spacer()
                            Text("\(calculateAverageEntriesPerMonth()) 件")
                                .font(.kleeOne(size: 14))
                                .foregroundColor(themeColors[themeColor])
                        }
                        .kawaiiBorder(colors: [themeColors[themeColor], themeColors[(themeColor + 1) % 4]], width: 1, cornerRadius: 8)
                        .padding(4)
                    }
                }
                .navigationTitle("統計")
            }
            .wavyBackground(color: themeColors[themeColor].opacity(0.1))
        }
    }
    
    // MARK: - Helper methods
    
    /// Format date in Japanese style
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    /// Get icon for category
    private func categoryIcon(for category: String) -> String {
        switch category {
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
    
    /// Get color for category
    private func categoryColor(for category: String) -> Color {
        switch category {
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
    
    /// Calculate average entries per month
    private func calculateAverageEntriesPerMonth() -> Int {
        if viewModel.diaries.isEmpty {
            return 0
        }
        
        guard let oldestDate = viewModel.diaries.map({ $0.date }).min(),
              let newestDate = viewModel.diaries.map({ $0.date }).max() else {
            return 0
        }
        
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: oldestDate, to: newestDate).month ?? 0
        
        // At least 1 month
        let monthCount = max(1, months + 1)
        
        return viewModel.diaries.count / monthCount
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DiaryViewModel())
    }
}