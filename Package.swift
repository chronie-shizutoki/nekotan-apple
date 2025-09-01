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
        .executable(name: "nekotan", targets: ["nekotan"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "nekotan",
            path: "Sources",
            resources: [
                .process("../fonts")
            ]
        ),
        .testTarget(
            name: "NekoTanTests",
            dependencies: ["nekotan"],
            path: "Tests/NekoTanTests"
        ),
        .testTarget(
            name: "NekoTanUITests",
            dependencies: ["nekotan"],
            path: "Tests/NekoTanUITests"
        )
    ])
