// swift-tools-version:5.0

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
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .upToNextMinor(from: "1.3.1")),
        .package(url: "https://github.com/sbertix/ComposableRequest", .upToNextMinor(from: "3.0.1"))
    ],
    targets: [
        .target(
            name: "Swiftagram",
            dependencies: ["ComposableRequest", "CryptoSwift"]
        ),
        .target(
            name: "SwiftagramKeychain",
            dependencies: ["Swiftagram", "KeychainSwift"]
        ),
        .testTarget(
            name: "SwiftagramTests",
            dependencies: ["Swiftagram", "SwiftagramKeychain"])
    ]
)
