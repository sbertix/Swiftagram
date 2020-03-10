//
//  SecretKey.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/03/2020.
//

import Foundation

public extension Secret {
    /// An `enum` describing `Secret` `CodingKey`.
    internal enum Key: CodingKey {
        /// The identifier.
        case identifier
        /// The cross site request forgery token.
        case crossSiteRequestForgery
        /// The session.
        case session
    }
}
