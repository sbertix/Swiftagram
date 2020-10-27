//
//  Device.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 27/10/20.
//

import Foundation

#if canImport(SwCrypt)
import SwCrypt
#endif

public extension Client {
    /// A `struct` holding reference to a device info.
    struct Device: Equatable, Codable, CustomStringConvertible {
        /// A `struct` holding reference to the device resolution.
        public struct Resolution: Equatable, Codable {
            /// The width.
            public var width: Int
            /// The height.
            public var height: Int
            /// The scale.
            public var scale: Int
            /// The DPI. Defaults to `nil`. Populated for Android devices alone.
            public var dpi: Int?

            /// Init.
            ///
            /// - parameters:
            ///     - width: A valid `Int`.
            ///     - height: A valid `Int`.
            ///     - scale: A valid `Int`.
            ///     - dpi: An optional `Int`. Defaults to `nil`.
            public init(width: Int, height: Int, scale: Int, dpi: Int? = nil) {
                self.width = width
                self.height = height
                self.scale = scale
                self.dpi = dpi
            }
        }

        /// A `struct` holding reference to the device hardware.
        ///
        /// Visit the link below to find out more about possible values:
        /// https://developers.whatismybrowser.com/useragents/explore/software_name/instagram
        public struct Hardware: Equatable, Codable {
            /// The model.
            public let model: String
            /// The brand. Populated for Android devices alone.
            public let brand: String?
            /// The boot. Populated for Andorid devices alone.
            public let boot: String?
            /// The CPU. Populated for Android devices alone.
            public let cpu: String?
            /// The manufacturer.
            public let manufacturer: String?
        }

        /// A `struct` holding reference to a device software.
        public struct Software: Equatable, Codable {
            /// The version, like *"iOS 13_3"* or *"29/10".*
            public let version: String
            /// The language, like _"en_US"_.
            public let language: String
        }

        /// The underlying device identifier.
        public let identifier: UUID
        /// The underlying phone identifier.
        public let phoneIdentifier: UUID
        /// The Google AdId.
        public let adIdentifier: UUID

        /// The hardware.
        public let hardware: Hardware
        /// The operating system.
        public let software: Software
        /// The resolution of the screen.
        public let resolution: Resolution

        // MARK: Lifecycle

        /// Generate a generic/Android device.
        ///
        /// - parameters:
        ///     - version: A valid `String`, like *"29/10"*.
        ///     - language: A valid `String`, like *"en_US"*.
        ///     - model: A valid `String`.
        ///     - brand: A valid `String`.
        ///     - boot: A valid `String`.
        ///     - cpu: A valid `String`.
        ///     - manufacturer: An optional `String`.
        ///     - resolution: A valid `Resolution`.
        ///     - identifier: A valid `UUID`. Defaults to a random one.
        ///     - phoneIdentifier: A valid `UUID`. Defaults to a random one.
        ///     - adIdentifier: A valid `UUID`. Defaults to a random one.
        public static func android(_ version: String,
                                   language: String,
                                   model: String,
                                   brand: String,
                                   boot: String,
                                   cpu: String,
                                   manufacturer: String?,
                                   resolution: Resolution,
                                   identifier: UUID = .init(),
                                   phoneIdentifier: UUID = .init(),
                                   adIdentifier: UUID = .init()) -> Device {
            return .init(identifier: identifier,
                         phoneIdentifier: phoneIdentifier,
                         adIdentifier: adIdentifier,
                         hardware: .init(model: model,
                                         brand: brand,
                                         boot: boot,
                                         cpu: cpu,
                                         manufacturer: manufacturer),
                         software: .init(version: version, language: language),
                         resolution: resolution)
        }

        /// Generate an iOS device.
        ///
        /// - parameters:
        ///     - version: A valid `String`, like _"iOS 13_3"_.
        ///     - language: A valid `String`, like *"en_US"*.
        ///     - model: A valid `String`, like _"iPhone 9,1"_.
        ///     - resolution: A valid `Resolution`.
        ///     - identifier: A valid `UUID`. Defaults to a random one.
        ///     - phoneIdentifier: A valid `UUID`. Defaults to a random one.
        ///     - adIdentifier: A valid `UUID`. Defaults to a random one.
        public static func iOS(_ version: String,
                               language: String,
                               model: String,
                               resolution: Resolution,
                               identifier: UUID = .init(),
                               phoneIdentifier: UUID = .init(),
                               adIdentifier: UUID = .init()) -> Device {
            return .init(identifier: identifier,
                         phoneIdentifier: phoneIdentifier,
                         adIdentifier: adIdentifier,
                         hardware: .init(model: model, brand: nil, boot: nil, cpu: nil, manufacturer: nil),
                         software: .init(version: version, language: language),
                         resolution: resolution)
        }

        // MARK: Accessories

        /// The Instagram device identifier.
        /// - note: Importing **SwiftagramCrypto** allows for actual `md5` computation, otherwise a dummy value is set instead.
        public var instagramIdentifier: String {
            #if canImport(SwCrypt)
            guard let data = identifier.uuidString.data(using: .utf8, allowLossyConversion: true) else {
                return [hardware.brand == nil ? "iOS-" : "android-",
                        identifier.uuidString.replacingOccurrences(of: "-", with: "").prefix(16).lowercased()].joined()
            }
            // Prepare encoded value.
            let encoded = CC.digest(data, alg: .md5).hexadecimalString().prefix(16).lowercased()
            return (hardware.brand == nil ? "iOS-" : "android-")+encoded
            #else
            return [hardware.brand == nil ? "iOS-" : "android-",
                    identifier.uuidString.replacingOccurrences(of: "-", with: "").prefix(16).lowercased()].joined()
            #endif
        }

        /// The underlying description, as a user agent component.
        public var description: String {
            guard let brand = hardware.brand,
                  let boot = hardware.boot,
                  let cpu = hardware.cpu,
                  let dpi = resolution.dpi else {
                // Return an iOS device user agent component.
                return [hardware.model,
                        software.version,
                        software.language.replacingOccurrences(of: "-", with: "_"),
                        software.language.replacingOccurrences(of: "_", with: "-"),
                        "scale=\(resolution.scale).00",
                        "\(resolution.width)x\(resolution.height)"]
                    .joined(separator: "; ")
            }
            // Return an Android device user agent component.
            return [software.version,
                    "\(dpi)dpi",
                    "\(resolution.width)x\(resolution.height)",
                    brand,
                    hardware.model,
                    boot,
                    cpu,
                    hardware.manufacturer,
                    software.language.replacingOccurrences(of: "-", with: "_")]
                .compactMap { $0 }
                .joined(separator: "; ")
        }

        /// The browser user agent.
        ///
        /// - warning: The process crashes if the `Device` is not of standard format.
        public var browserDescription: String {
            if software.version.contains("iOS") {
                // Return an iOS browser user agent.
                return ["Mozilla/5.0 (iPhone; CPU iPhone OS \(software.version.replacingOccurrences(of: "iOS ", with: "")) like Mac OS X)",
                        "AppleWebKit/602.1 (KHTML, like Gecko)",
                        "Version/10.0 Mobile/14E5239e Safari/602.1"]
                    .joined(separator: " ")
            } else if software.version.contains("/") {
                // Return an Android browser user agent.
                return ["Mozilla/5.0 (Linux; Android \(software.version.split(separator: "/").last ?? "10"); \(hardware.model))",
                        "AppleWebKit/602.1 (KHTML, like Gecko)",
                        "Chrome/79.0.3945.93 Mobile Safari/602.1"]
                    .joined(separator: " ")
            } else {
                fatalError("Invalid device browser user agent.")
            }
        }
    }
}
