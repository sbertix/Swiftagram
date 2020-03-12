//
//  Requestable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 12/03/2020.
//

import Foundation

/// A `protocol` describing a generic endpoint-like item.
public protocol Requestable {
    /// Compute the `URLRequest`.
    func request() -> URLRequest?

    /// Append `item`.
    func wrap(_ item: String) -> Self

    /// Append `body`. Empty `self.body` if `nil`.
    func body(_ body: [String: String?]?) -> Self

    /// Append `queries`. Empty `self.queries` if `nil`.
    func query(_ queries: [String: String?]?) -> Self

    /// Append `headerFields`. Empty `self.headerFields` if `nil`.
    func headerFields(_ headerFields: [String: String]?) -> Self

    /// Set `method`.
    /// - parameter method: A `Method` value.
    func method(_ method: Endpoint.Method) -> Self
}

public extension Requestable {
    /// Lock `self`.
    func locked() -> Secreted<Self> { return .init(endpoint: self) }

    /// Append `item`.
    func wrap<Item>(_ item: Item) -> Self where Item: CustomStringConvertible {
        return wrap(item.description)
    }

    /// Append to `body`.
    func body(key: String, value: String?) -> Self { return body([key: value]) }

    /// Append to `queries`.
    func query(key: String, value: String?) -> Self { return query([key: value]) }

    /// Append default `headerFields`.
    func defaultHeaderFields() -> Self {
        return headerFields(
            [Headers.acceptLanguageKey: Headers.acceptLanguageValue,
             Headers.contentTypeKey: Headers.contentTypeApplicationFormValue,
             Headers.igCapabilitiesKey: Headers.igCapabilitiesValue,
             Headers.igConnectionTypeKey: Headers.igConnectionTypeValue,
             Headers.userAgentKey: Headers.userAgentValue]
        )
    }
}
