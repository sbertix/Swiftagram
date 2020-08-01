//
//  Aliases.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 01/08/20.
//

import Foundation

import ComposableRequestCrypto
import Swiftagram

/// A `struct` holding reference to all `Secret`s stored in the keychain.
/// - note: `
///     KeychainStorage` is the encoded and ready-to-use alternative to `UserDefaultsStorage`.
@available(*, deprecated, message: "import `ComposableRequest` and use `UserDefaultsStorage<Secret>` instead")
public typealias KeychainStorage = ComposableRequestCrypto.KeychainStorage<Secret>
