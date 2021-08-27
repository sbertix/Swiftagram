// swift-tools-version:5.2

import Foundation
import PackageDescription

// MARK: Definitions

let package = Package(
    name: "Swiftagram",
    // Supported versions.
    platforms: [.iOS("13.0"),
                .macOS("10.15"),
                .tvOS("13.0"),
                .watchOS("6.0")],
    // Exposed libraries.
    products: [.library(name: "Swiftagram",
                        targets: ["Swiftagram"]),
               .library(name: "SwiftagramCrypto",
                        targets: ["SwiftagramCrypto"])],
    // Package dependencies.
    dependencies: [.package(url: "https://github.com/sbertix/ComposableRequest", .upToNextMinor(from: "6.0.1")),
                   .package(url: "https://github.com/sbertix/SwCrypt.git", .upToNextMinor(from: "5.1.0"))],
    // All targets.
    targets: [.target(name: "Swiftagram",
                      dependencies: [.product(name: "Requests", package: "ComposableRequest"),
                                     .product(name: "Storages", package: "ComposableRequest")]),
              .target(name: "SwiftagramCrypto",
                      dependencies: ["Swiftagram",
                                     .product(name: "EncryptedStorages", package: "ComposableRequest"),
                                     .product(name: "SwCrypt", package: "SwCrypt")]),
              .testTarget(name: "SwiftagramTests",
                          dependencies: ["Swiftagram", "SwiftagramCrypto"])]
)

if ProcessInfo.processInfo.environment["TARGETING_WATCHOS"] == "true" {
    // #workaround(xcodebuild -version 11.6, Test targets don’t work on watchOS.) @exempt(from: unicode)
    package.targets.removeAll(where: { $0.isTest })
}
