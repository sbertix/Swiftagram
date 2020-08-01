//
//  Aliases.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 01/08/20.
//

import Foundation

import ComposableRequest

/// A `struct` holding reference to all transient `Secret`s.
/// - note: Use when only dealing with one-shot `Secret`s.
@available(*, deprecated, message: "import `ComposableRequest` and use `TransientStorage<Secret>` instead")
public typealias TransientStorage = ComposableRequest.TransientStorage<Secret>

/// A `struct` holding reference to all `Secret`s stored in the `UserDefaults`.
/// - warning: `UserDefaults` are not safe for storing `Secret`s. **DO NOT USE THIS IN PRODUCTION**.
/// - note: `
///     KeychainStorage` is the encoded and ready-to-use alternative to `UserDefaultsStorage`.
///     Add https://github.com/evgenyneu/keychain-swift to your dependencies and import it to start using it.
@available(*, deprecated, message: "import `ComposableRequest` and use `UserDefaultsStorage<Secret>` instead")
public typealias UserDefaultsStorage = ComposableRequest.UserDefaultsStorage<Secret>
