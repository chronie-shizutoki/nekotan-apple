import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
// For Apple platforms, use SwiftUI lifecycle
import NekoTanLib

@main
struct NekoTanAppMain {
    static func main() {
        if #available(iOS 14.0, macOS 11.0, *) {
            NekoTanApp.main()
        } else {
            // Fallback for older OS versions
            print("This app requires iOS 14+ or macOS 11+")
        }
    }
}
#else
// For other platforms, use the existing main.swift
// This will be used when not on Apple platforms
print("Starting NekoTan on non-Apple platform")
// Add your non-Apple platform initialization here
#endif