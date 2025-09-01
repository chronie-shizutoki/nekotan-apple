// Entry point for the nekoTan application
import SwiftUI
import nekoTan

// Start the application
if #available(iOS 14.0, macOS 11.0, *) {
    NekoTanAppMain.main()
} else {
    print("This app requires iOS 14+ or macOS 11+")
}
