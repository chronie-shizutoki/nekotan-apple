//
//  NekoTanApp.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI
import CoreText
import CoreGraphics

// Import animation components
import Combine

// Font registration extension
extension Font {
    static func registerCustomFonts() {
        // Get the bundle where the fonts are located
        guard let bundleURL = Bundle.module.url(forResource: "fonts", withExtension: nil) else {
            print("Could not find fonts directory in bundle")
            return
        }
        
        do {
            // Get all font files in the directory
            let fontFiles = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension.lowercased() == "ttf" }
            
            // Register each font
            for fontFile in fontFiles {
                if let fontData = try? Data(contentsOf: fontFile),
                   let provider = CGDataProvider(data: fontData as CFData),
                   let font = CGFont(provider) {
                    var error: Unmanaged<CFError>?
                    if !CTFontManagerRegisterGraphicsFont(font, &error) {
                        print("Error registering font: \(fontFile.lastPathComponent)")
                    } else {
                        print("Successfully registered font: \(fontFile.lastPathComponent)")
                    }
                }
            }
        } catch {
            print("Error accessing fonts directory: \(error)")
        }
    }
    
    // Custom font accessor
    static func kleeOne(size: CGFloat) -> Font {
        return Font.custom("KleeOne-Regular", size: size)
    }
}

/// Main application entry point
@main
struct NekoTanApp: App {
    // MARK: - Properties
    
    /// Shared diary view model
    @StateObject private var diaryViewModel = DiaryViewModel()
    
    // MARK: - Initialization
    
    init() {
        // Register custom fonts when app starts
        Font.registerCustomFonts()
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diaryViewModel)
        }
    }
}