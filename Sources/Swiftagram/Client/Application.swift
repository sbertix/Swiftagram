//
//  Application.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 27/10/20.
//

import Foundation

public extension Client {
    /// A `struct` holding reference to the Instagram app info.
    struct Application: Equatable, Codable, CustomStringConvertible {
        /// The client's version. Android devices' versions end with _" Android"_.
        public let version: String
        /// The client's code.
        public let code: String

        /// Create an Android client.
        ///
        /// - parameters:
        ///     - version: A valid `String`. Defaults to _"160.1.0.31.120"_.
        ///     - code: A valid `String`. Defaults to _"185203708"_.
        /// - returns: A valid `Client`.
        public static func android(_ version: String = "160.1.0.31.120", code: String = "246979827") -> Application {
            return .init(version: version+" Android", code: code)
        }

        /// Create an iOS client.
        ///
        /// - parameters:
        ///     - version: A valid `String`. Defaults to _"121.0.0.29.119"_.
        ///     - code: A valid `String`. Defaults to _"185203708"_.
        /// - returns: A valid `Client`.
        public static func iOS(_ version: String = "160.1.0.31.120", code: String = "246979827") -> Application {
            return .init(version: version, code: code)
        }

        /// A valid description.
        public var description: String { return "Instagram \(version)" }
    }
}
