//
//  ResponseError.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/08/20.
//

import Foundation

/// An `enum` holding reference to possible `Error`s in the response.
public enum ResponseError: Error {
    /// A generic `Error`.
    case generic(String)
    /// Unforseen `status`.
    /// Check the underlying `Wrapper` to find out more.
    case unforseen(String?)
    /// The `status` was marked as `fail`, but no `message` was provided.
    /// Check the underlying `Wrapper` to find out more.
    case unknown
}
