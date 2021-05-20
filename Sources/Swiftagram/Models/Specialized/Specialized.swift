//
//  Specialized.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/08/20.
//

import Foundation

/// An `enum` holding reference to possible `Error`s in the response.
public enum SpecializedError: Error {
    /// A generic `Error`.
    case generic(String, response: Wrapper)
    /// Unforseen `status`.
    /// Check the underlying `Wrapper` to find out more.
    case unforseen(String?, response: Wrapper)
    /// The `status` was marked as `fail`, but no `message` was provided.
    /// Check the underlying `Wrapper` to find out more.
    case unknown(response: Wrapper)
}

/// A `protocol` describing a generic response returning an element of `Response`.
public protocol Specialized: Wrapped {
    /// An optional `SpecializedError` message returned by a response.
    /// Default emplementation returns failing description, if it exists,
    /// otherwise `.unknown` if `status` is not `ok`, and `nil` if it is.
    var error: SpecializedError? { get }
}

public extension Specialized {
    /// The response status.
    @available(*, deprecated, message: "check for `error` instead")
    var status: String! { self["status"].string() }

    /// An optional `SpecializedError` message returned by a response.
    /// It returns the failing description, if it exists, otherwise `.unknown` if `status` is not `ok`, and `nil` if it is.
    var error: SpecializedError? {
        switch self["status"].string() {
        case "ok":
            return nil
        case "fail":
            return self["message"].string().flatMap { .generic($0, response: self.wrapped) }
                ?? .unknown(response: self.wrapped)
        case let status:
            return .unforseen(status, response: self.wrapped)
        }
    }
}
