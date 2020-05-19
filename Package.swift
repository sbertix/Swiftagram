// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Swiftagram",
    products: [
        .library(
            name: "Swiftagram",
            targets: ["Swiftagram"]
        ),
        .library(
            name: "SwiftagramKeychain",
            targets: ["SwiftagramKeychain"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", .upToNextMinor(from: "19.0.0")),
        .package(url: "https://github.com/soyersoyer/SwCrypt", .upToNextMinor(from: "5.1.0")),
        .package(url: "https://github.com/sbertix/ComposableRequest", .branch("development")),
    ],
    targets: [
        .target(
            name: "Swiftagram",
            dependencies: ["ComposableRequest", "SwCrypt"]
        ),
        .target(
            name: "SwiftagramKeychain",
            dependencies: ["Swiftagram", "KeychainSwift"]
        ),
        .testTarget(
            name: "SwiftagramTests",
            dependencies: ["Swiftagram", "SwiftagramKeychain"]
        )
    ]
)
