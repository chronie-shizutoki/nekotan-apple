//
//  ContentView.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI

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
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Diary list tab
                DiaryListView(viewModel: diaryViewModel)
                    .tabItem {
                        Label("Diary", systemImage: "book.fill")
                    }
                    .tag(0)
                
                // Statistics tab (placeholder for future implementation)
                StatisticsView(viewModel: diaryViewModel)
                    .tabItem {
                        Label("Statistics", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                
                // Settings tab (placeholder for future implementation)
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
            }
            
            // Apply sakura effect if animations are enabled
            if enableAnimations {
                Color.clear.sakuraEffect(petalCount: 30)
            }
        }
    }
}

// MARK: - StatisticsView

/// View for displaying diary statistics
struct StatisticsView: View {
    // MARK: - Properties
    
    /// Diary view model
    @ObservedObject var viewModel: DiaryViewModel
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            List {
                // Category statistics
                Section(header: Text("Categories").font(.kleeOne(size: 18))) {
                    ForEach(viewModel.categories.filter { $0.count > 0 }.sorted(by: { $0.count > $1.count }).prefix(10)) { category in
                        HStack {
                            Text(category.name)
                                .font(.kleeOne(size: 16))
                            Spacer()
                            Text("\(category.count)")
                                .foregroundColor(.secondary)
                                .font(.kleeOne(size: 14))
                        }
                    }
                }
                
                // Tag statistics
                Section(header: Text("Tags").font(.kleeOne(size: 18))) {
                    ForEach(viewModel.tags.filter { $0.count > 0 }.sorted(by: { $0.count > $1.count }).prefix(10)) { tag in
                        HStack {
                            Text(tag.name)
                                .font(.kleeOne(size: 16))
                            Spacer()
                            Text("\(tag.count)")
                                .foregroundColor(.secondary)
                                .font(.kleeOne(size: 14))
                        }
                    }
                }
                
                // General statistics
                Section(header: Text("General")) {
                    HStack {
                        Text("Total Entries")
                        Spacer()
                        Text("\(viewModel.diaries.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    if let oldestDate = viewModel.diaries.map({ $0.date }).min() {
                        HStack {
                            Text("First Entry")
                            Spacer()
                            Text(oldestDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let newestDate = viewModel.diaries.map({ $0.date }).max() {
                        HStack {
                            Text("Latest Entry")
                            Spacer()
                            Text(newestDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

// MARK: - SettingsView

/// View for application settings
struct SettingsView: View {
    // MARK: - Properties
    
    /// State for dark mode preference
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    /// State for font size preference
    @AppStorage("fontSize") private var fontSize = 1 // 0: small, 1: medium, 2: large
    
    /// State for showing about information
    @State private var showingAbout = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // Appearance settings
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    
                    Picker("Font Size", selection: $fontSize) {
                        Text("Small").tag(0)
                        Text("Medium").tag(1)
                        Text("Large").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Toggle("Enable Animations", isOn: $enableAnimations)
                        .onChange(of: enableAnimations) { newValue in
                            // Force refresh the view when animation setting changes
                            // This is needed to apply/remove the sakura effect
                        }
                }
                
                // About section
                Section {
                    Button("About NekoTan") {
                        showingAbout = true
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAbout) {
                aboutView
            }
        }
    }
    
    // MARK: - Subviews
    
    /// About view
    private var aboutView: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.accentColor)
                        
                        Text("NekoTan's Diary")
                            .font(.title)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Section(header: Text("About")) {
                    Text("NekoTan's Diary is a simple diary application for recording your daily thoughts and experiences. Organize your entries with categories and tags, and easily search through your past memories.")
                }
                
                Section(header: Text("Credits")) {
                    Text("Original web application by Shizuki Nekotan")
                    Text("Swift version developed for Apple platforms")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingAbout = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DiaryViewModel())
    }
}