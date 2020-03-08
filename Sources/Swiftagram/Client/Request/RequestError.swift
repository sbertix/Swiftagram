//
//  RequestError.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Request {
    /// An `enum` holding reference to `Request`-specific `Error`s.
    enum Error: Swift.Error {
        /// Invalid `Data`.
        case invalidData
        /// Invalid `URL`.
        case invalidEndpoint
    }
}
