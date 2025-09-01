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
        .executable(name: "nekotan", targets: ["nekotan"]),
        .library(name: "NekoTanLib", targets: ["NekoTanLib"])
    ],
    targets: [
        // Main executable target
        .executableTarget(
            name: "nekotan",
            dependencies: ["NekoTanLib"],
            resources: [
                .copy("../fonts")
            ]
        ),
        // Library target for reuse across platforms
        .target(
            name: "NekoTanLib",
            resources: [
                .copy("../fonts")
            ]
        ),
    ]
)
