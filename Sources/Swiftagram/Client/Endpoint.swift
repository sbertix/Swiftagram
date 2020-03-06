//
//  Endpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

@dynamicMemberLookup
/// A `struct` defining all possible `Endpoint`s.
public struct Endpoint: Hashable {
    /// A `[String]` composed of all path components.
    internal var components: [String]
    /// A `[String: String]` composed of all custom header fields. Defaults to `[:]`.
    internal var headerFields: [String: String]

    /// Compute the `URLRequest`.
    public var request: URLRequest? {
        URL(string: components.joined(separator: "/"))
            .flatMap { URLRequest(url: $0) }
    }

    // MARK: Lifecycle
    /// Init.
    /// - parameter components: A `Collection` of `String`s, forming a valid `https` address, when joined together using `/`.
    /// - parameter headerFields. A `Dictionary` of `(key: String, value: String)`, forming valid header fields.
    public init(components: [String],
                headerFields: [String: String] = [:]) {
        self.components = components
        self.headerFields = headerFields
    }

    // MARK: Composition
    /// An `Endpoint` pointing to `api/v1`.
    public static var version1: Endpoint { return .init(components: ["https://i.instagram.com/api/v1"]) }
    /// An `Endpoint`pointing to `api/v2`.
    public static var version2: Endpoint { return .init(components: ["https://i.instagram.com/api/v2"]) }
    /// An `Endpoint` pointing to the Instagram homepage.
    public static var generic: Endpoint { return .init(components: ["https://www.instagram.com"]) }

    /// Append `item`.
    public func appending<Item>(_ item: Item) -> Endpoint where Item: LosslessStringConvertible {
        var copy = self
        copy.components.append(String(item))
        return copy
    }
    /// Append `item`.
    public func appending<Item>(_ item: Item) -> Endpoint where Item: CustomStringConvertible {
        var copy = self
        copy.components.append(item.description)
        return copy
    }
    /// Append `component`.
    public subscript(dynamicMember component: String) -> Endpoint {
        var copy = self
        copy.components.append(component)
        return copy
    }

    /// Append `headerFields`.
    public func headerFields(_ headerFields: [String: String]) -> Endpoint {
        var copy = self
        copy.headerFields = copy.headerFields.merging(headerFields, uniquingKeysWith: { _, rhs in rhs })
        return copy
    }
}
