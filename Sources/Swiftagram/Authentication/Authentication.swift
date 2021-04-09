//
//  Authentication.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/04/21.
//

import Foundation

/// A `protocol` defining a generic authentication process.
public protocol Authentication {
    /// Authenticate the given user.
    ///
    /// - returns: A valid `Publisher`.
    func authenticate() -> AnyPublisher<Secret, Error>
}
