// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nekotan",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(name: "NekoTanLib", targets: ["NekoTanLib"]),
        .executable(name: "NekoTanApp", targets: ["NekoTanApp"])
    ],
    dependencies: [
        // Add SwiftLint as a dependency for code quality
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.52.4")
    ],
    targets: [
        // Library target for reuse across platforms
        .target(
            name: "NekoTanLib",
            dependencies: [],
            resources: [
                .copy("../../fonts")
            ]
        ),
        // Executable target that uses the library
        .executableTarget(
            name: "NekoTanApp",
            dependencies: ["NekoTanLib"],
            path: "Sources",
            resources: [
                .copy("../fonts")
            ]
        ),
        // Unit tests
        .testTarget(
            name: "NekoTanTests",
            dependencies: ["NekoTanLib"],
            path: "Tests/NekoTanTests"
        ),
        // UI tests
        .testTarget(
            name: "NekoTanUITests",
            dependencies: ["NekoTanLib"],
            path: "Tests/NekoTanUITests"
        )
    ])
