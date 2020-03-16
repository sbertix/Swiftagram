// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Swiftagram",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
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
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/sbertix/ComposableRequest", from: "1.0.1"),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "19.0.0"),
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
