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
            name: "SwiftagramCrypto",
            targets: ["SwiftagramCrypto"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", .upToNextMinor(from: "19.0.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .upToNextMinor(from: "1.3.1")),
        .package(url: "https://github.com/sbertix/ComposableRequest", .upToNextMinor(from: "4.0.0")),
    ],
    targets: [
        .target(
            name: "Swiftagram",
            dependencies: ["ComposableRequest"]
        ),
        .target(
            name: "SwiftagramCrypto",
            dependencies: ["Swiftagram", "CryptoSwift", "KeychainSwift"]
        ),
        .testTarget(
            name: "SwiftagramTests",
            dependencies: ["Swiftagram", "SwiftagramCrypto"]
        )
    ]
)
