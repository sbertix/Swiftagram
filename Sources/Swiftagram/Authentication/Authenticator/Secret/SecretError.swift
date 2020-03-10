//
//  SecretError.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/03/2020.
//

import Foundation

public extension Secret {
    /// An `enum` describing all possible `Secret` `Error`s.
    enum Error: Swift.Error {
        /// A decoding error.
        case invalidCookie
    }
}
