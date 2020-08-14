//
//  Deprecations.swift
//  SwiftagramCrypto
//
//  This file contains a list of all `unavailable` and `deprecated` declerations,
//  referencing (at least) the version in which they are going to be removed.
//
//  Created by Stefano Bertagno on 14/08/2020.
//

import Foundation

import ComposableRequestCrypto
import Swiftagram

public extension Endpoint.Media {
    /// Like the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, message: "use `Endpoint.Media.Posts.like(_:)`; it will be removed in `4.1.0`.")
    static func like(_ identifier: String) -> Endpoint.Disposable<Status> {
        return Posts.like(identifier)
    }

    /// Unlike the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, message: "use `Endpoint.Media.Posts.unlike(_:)`; it will be removed in `4.1.0`.")
    static func unlike(_ identifier: String) -> Endpoint.Disposable<Status> {
        return Posts.unlike(identifier)
    }
}

/// A `struct` holding reference to all `Secret`s stored in the keychain.
/// - note: `
///     KeychainStorage` is the encoded and ready-to-use alternative to `UserDefaultsStorage`.
/// - warning: This will be removed in version `4.1.0`.
@available(
    *,
    deprecated,
    message: "import `ComposableRequestCrypto` and use `KeychainStorage<Secret>` instead; this alias will be removed in `4.1.0`."
)
public typealias KeychainStorage = ComposableRequestCrypto.KeychainStorage<Secret>
