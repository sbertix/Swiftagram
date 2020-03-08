// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Swiftagram",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Swiftagram",
            targets: ["Swiftagram"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "16.0.0"),
    ],
    targets: [
        .target(
            name: "Swiftagram",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftagramTests",
            dependencies: ["KeychainSwift", "Swiftagram"])
    ]
)
