// swift-tools-version:5.2

import Foundation
import PackageDescription

let package = Package(
    name: "Swiftagram",
    // Supported versions.
    platforms: [.iOS(.v9),
                .macOS(.v10_12),
                .tvOS(.v11),
                .watchOS(.v3)],
    // Exposed libraries.
    products: [.library(name: "Swiftagram",
                        targets: ["Swiftagram"]),
               .library(name: "SwiftagramCrypto",
                        targets: ["SwiftagramCrypto"])],
    // Package dependencies.
    dependencies: [.package(url: "https://github.com/sbertix/ComposableRequest.git", .branch("development")),
                   .package(url: "https://github.com/sbertix/SwCrypt.git", .upToNextMinor(from: "5.1.0")),
                   .package(url: "https://github.com/sbertix/Swiftchain.git", .upToNextMinor(from: "1.0.0"))],
    // All targets.
    targets: [.target(name: "Swiftagram",
                      dependencies: [.product(name: "ComposableRequest", package: "ComposableRequest"),
                                     .product(name: "ComposableStorage", package: "ComposableRequest")]),
              .target(name: "SwiftagramCrypto",
                      dependencies: [.target(name: "Swiftagram"),
                                     .product(name: "SwCrypt", package: "SwCrypt"),
                                     .product(name: "Swiftchain", package: "Swiftchain")]),
              .testTarget(name: "SwiftagramTests",
                          dependencies: [.target(name: "Swiftagram"),
                                         .target(name: "SwiftagramCrypto")])]
)

if ProcessInfo.processInfo.environment["TARGETING_WATCHOS"] == "true" {
  // #workaround(xcodebuild -version 11.6, Test targets don’t work on watchOS.) @exempt(from: unicode)
  package.targets.removeAll(where: { $0.isTest })
}
