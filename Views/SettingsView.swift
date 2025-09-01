//
//  SettingsView.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI
import UIKit

/// View for application settings with cute design
struct SettingsView: View {
    // MARK: - Properties
    
    /// Dark mode setting
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    /// Animation toggle
    @AppStorage("enableAnimations") private var enableAnimations = true
    
    /// Font size setting
    @AppStorage("fontSize") private var fontSize = 1 // 0: small, 1: medium, 2: large
    
    /// Theme color setting
    @AppStorage("themeColor") private var themeColor = 0 // 0: pink, 1: purple, 2: blue, 3: yellow
    
    /// Cherry blossom effect setting
    @AppStorage("showSakuraEffect") private var showSakuraEffect = true
    
    /// Notification setting
    @AppStorage("enableNotifications") private var enableNotifications = true
    
    /// Daily reminder setting
    @AppStorage("dailyReminderTime") private var dailyReminderTime = "20:00"
    
    /// User feedback setting
    @AppStorage("enableFeedback") private var enableFeedback = true
    
    /// Diary view model
    @EnvironmentObject private var viewModel: DiaryViewModel
    
    /// Import state
    @State private var isImporting = false
    
    /// Theme colors array
    private let themeColors = [
        Color.pink,
        Color.purple,
        Color.blue,
        Color.yellow
    ]
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // Appearance Section
                Section(header: Text("見た目").font(.kleeOne(size: 18))) {
                    // Dark Mode Toggle
                    Toggle("ダークモード", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) {
                            // Update appearance when dark mode setting changes
                            if isDarkMode {
                                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
                            } else {
                                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                            }
                        }
                    
                    // Animation Toggle
                    Toggle("アニメーション", isOn: $enableAnimations)
                    
                    // Cherry Blossom Effect Toggle
                    Toggle("桜のエフェクト", isOn: $showSakuraEffect)
                    
                    // Font Size Picker
                    Picker("フォントサイズ", selection: $fontSize) {
                        Text("小さい").tag(0)
                        Text("普通").tag(1)
                        Text("大きい").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Theme Color Picker
                    Section(header: Text("テーマカラー").font(.kleeOne(size: 16))) {
                        HStack(spacing: 12) {
                            Button(action: { themeColor = 0 }) {
                                Circle().fill(Color.pink).frame(width: 40, height: 40)
                                    .overlay(themeColor == 0 ? Image(systemName: "checkmark").foregroundColor(.white) : nil)
                                    .bounceAnimation(strength: 0.5, duration: 0.5)
                            }
                            Button(action: { themeColor = 1 }) {
                                Circle().fill(Color.purple).frame(width: 40, height: 40)
                                    .overlay(themeColor == 1 ? Image(systemName: "checkmark").foregroundColor(.white) : nil)
                                    .bounceAnimation(strength: 0.5, duration: 0.5)
                            }
                            Button(action: { themeColor = 2 }) {
                                Circle().fill(Color.blue).frame(width: 40, height: 40)
                                    .overlay(themeColor == 2 ? Image(systemName: "checkmark").foregroundColor(.white) : nil)
                                    .bounceAnimation(strength: 0.5, duration: 0.5)
                            }
                            Button(action: { themeColor = 3 }) {
                                Circle().fill(Color.yellow).frame(width: 40, height: 40)
                                    .overlay(themeColor == 3 ? Image(systemName: "checkmark").foregroundColor(.white) : nil)
                                    .bounceAnimation(strength: 0.5, duration: 0.5)
                            }
                        }
                    }
                }
                
                // Notification Section
                Section(header: Text("通知").font(.kleeOne(size: 18))) {
                    // Notification Toggle
                    Toggle("通知を有効にする", isOn: $enableNotifications)
                        .onChange(of: enableNotifications) {
                            if enableNotifications {
                                setupDailyReminder()
                            } else {
                                cancelDailyReminder()
                            }
                        }
                    
                    // Daily Reminder Time Picker
                    if enableNotifications {
                        HStack {
                            Text("日記を書くリマインダー")
                                .font(.kleeOne(size: 16))
                            Spacer()
                            Button(action: showTimePicker) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(themeColors[themeColor])
                                    Text(dailyReminderTime)
                                        .font(.kleeOne(size: 16))
                                        .foregroundColor(themeColors[themeColor])
                                }
                            }
                        }
                    }
                    
                    // User Feedback Toggle
                    Toggle("操作フィードバック", isOn: $enableFeedback)
                }
                
                // Data Management Section
                Section(header: Text("データ管理").font(.kleeOne(size: 18))) {
                    Button(action: exportCSV) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                                .foregroundColor(Color.purple)
                            Text("CSVにエクスポート")
                                .font(.kleeOne(size: 16))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.gray)
                        }
                        .kawaiiBorder(colors: [Color.purple, Color.pink], width: 1, cornerRadius: 8)
                        .padding(8)
                    }
                    
                    Button(action: { isImporting = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundColor(Color.blue)
                            Text("CSVからインポート")
                                .font(.kleeOne(size: 16))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.gray)
                        }
                        .kawaiiBorder(colors: [Color.blue, Color.cyan], width: 1, cornerRadius: 8)
                        .padding(8)
                    }
                }

                // About Section
                Section(header: Text("アプリについて").font(.kleeOne(size: 18))) {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color.pink)
                                .floatAnimation(amplitude: 5, frequency: 1)
                            Text("ネコタンの日記")
                                .font(.kleeOne(size: 24))
                                .foregroundColor(Color.pink)
                            Text("バージョン 1.0")
                                .font(.kleeOne(size: 14))
                                .foregroundColor(Color.purple)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("設定")
            .wavyBackground(color: themeColors[themeColor].opacity(0.1))
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleCSVImport(result)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Export diary data to CSV
    private func exportCSV() {
        let csvString = viewModel.exportToCSV()
        
        // Create a temporary file URL
        let fileManager = FileManager.default
        let tempDir = NSTemporaryDirectory()
        let fileName = "ネコタン日記_\(Date().formatted(date: .numeric, time: .omitted)).csv"
        let fileURL = URL(fileURLWithPath: tempDir).appendingPathComponent(fileName)
        
        do {
            // Write CSV string to file
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Present share sheet
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
            
            if enableFeedback {
                viewModel.showNotification("エクスポートが完了しました🎉")
            }
        } catch {
            viewModel.showNotification("エクスポートに失敗しました😢")
        }
    }
    
    /// Handle CSV import
    private func handleCSVImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            
            do {
                let csvString = try String(contentsOf: fileURL, encoding: .utf8)
                viewModel.importFromCSV(csvString) { result in
                    if case .failure(let error) = result {
                        viewModel.showNotification("インポートに失敗しました😢")
                    } else if enableFeedback {
                        viewModel.showNotification("インポートが完了しました🎉")
                    }
                }
            } catch {
                viewModel.showNotification("ファイルの読み込みに失敗しました😢")
            }
        case .failure:
            viewModel.showNotification("ファイルの選択に失敗しました😢")
        }
    }
    
    /// Show time picker for daily reminder
    private func showTimePicker() {
        // In a real iOS app, we would present a time picker here
        // For simplicity, we'll just toggle between a few preset times
        let times = ["08:00", "12:00", "18:00", "20:00", "22:00"]
        if let currentIndex = times.firstIndex(of: dailyReminderTime) {
            dailyReminderTime = times[(currentIndex + 1) % times.count]
        } else {
            dailyReminderTime = "20:00"
        }
        
        if enableNotifications {
            setupDailyReminder()
        }
        
        if enableFeedback {
            viewModel.showNotification("リマインダー時間を設定しました✨")
        }
    }
    
    /// Setup daily reminder notification
    private func setupDailyReminder() {
        // In a real iOS app, we would use UNUserNotificationCenter here
        // For this example, we'll just show a notification
        if enableFeedback {
            viewModel.showNotification("日記のリマインダーを設定しました！\n毎日 \(dailyReminderTime) にお知らせします💕")
        }
    }
    
    /// Cancel daily reminder notification
    private func cancelDailyReminder() {
        if enableFeedback {
            viewModel.showNotification("日記のリマインダーを解除しました😊")
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DiaryViewModel())
    }
}