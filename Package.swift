// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombineCoreData",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15"),
        .tvOS("13.0"),
        .watchOS("6.0")
    ],
    products: [
        .library(
            name: "CombineCoreData",
            targets: ["CombineCoreData"]),
    ],
    targets: [
        .target(
            name: "CombineCoreData",
            dependencies: []),
        .target(
            name: "Books",
            dependencies: ["CombineCoreData"]),
        .testTarget(
            name: "CombineCoreDataTests",
            dependencies: ["CombineCoreData", "Books"]),
    ]
)
