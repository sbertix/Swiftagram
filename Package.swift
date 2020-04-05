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
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", Version("19.0.0")..<Version("19.1.0")),
        .package(url: "https://github.com/sbertix/ComposableRequest", Version("2.1.0")..<Version("2.2.0"))
    ],
    targets: [
        .target(
            name: "Swiftagram",
            dependencies: ["ComposableRequest"]
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
