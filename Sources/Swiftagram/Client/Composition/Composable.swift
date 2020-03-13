//
//  Composable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest`.
@dynamicMemberLookup
public protocol Composable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    func request() -> URLRequest?

    /// Append `pathComponent`.
    /// - parameter pathComponent: A `String` representing a path component.
    func append(_ pathComponent: String) -> Self

    /// Append to `queryItems`. Empty `queryItems` if `nil`.
    /// - parameter method: A `ComposableRequest.Method` value.
    func query(_ items: [String: String?]?) -> Self

    /// Set `method`.
    /// - parameter method: A `ComposableRequest.Method` value.
    func method(_ method: ComposableRequest.Method) -> Self

    /// Set `body`.
    /// - parameter body: A valid `ComposableRequest.Body`.
    func body(_ body: ComposableRequest.Body) -> Self

    /// Append to `ComposableRequest.Body.parameters`. Empty `body` if `nil`.
    /// - parameter parameters: An optional `Dictionary` of  option`String`s.
    func body(_ parameters: [String: String?]?) -> Self

    /// Append to `headerFields`. Empty `headerFields` if `nil`.
    /// - parameter fields: An optional `Dictionary` of  option`String`s.
    func header(_ fields: [String: String?]?) -> Self
}

public extension Composable {
    /// Append `pathComponent`.
    /// - parameter pathComponent: A `String` representing a path component.
    subscript(dynamicMember pathComponent: String) -> Self {
        return append(pathComponent)
    }

    /// Append `pathComponent`.
    /// - parameter pathComponent: A `CustomStringConvertible` representing a path component.
    func append<PathComponent: CustomStringConvertible>(_ pathComponent: PathComponent) -> Self {
        return append(pathComponent.description)
    }

    /// Set `queryItems`.
    /// - parameter items: An `Array` of `URLQueryItem`s.
    func query(_ items: [URLQueryItem]) -> Self {
        return query(nil)
            .query(Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value) }))
    }

    /// Append to `queryItems`.
    /// - parameters:
    ///     - key: A `String` representing a `URLQueryItem.name`.
    ///     - value: An optional `String` representing a `URLQueryItem.value`.
    func query(_ key: String, value: String?) -> Self {
        return query([key: value])
    }

    /// Append to `ComposableRequest.Body.parameters`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func body(_ key: String, value: String?) -> Self {
        return body([key: value])
    }

    /// Append to `headerFields`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func header(_ key: String, value: String?) -> Self {
        return header([key: value])
    }

    /// Append to `headerFields`.
    func defaultHeader() -> Self {
        return header(
            ["Accept-Language": "en-US",
             "Content-Type": "application/x-www-form-urlencoded",
             "X-IG-Capabilities": "3brTvw==",
             "X-IG-Connection-Type": "WIFI",
             "User-Agent": ["Instagram 85.0.0.21.100 Android ",
                            "(21/5.0.2; 640dpi; 1440x2560; Sony; C6603; C6603; qcom; en_US; 95414346)"]
                .joined()]
        )
    }

    // MARK: Accessories
    /// Lock `self` until a `Secret` is used for authenticating the request.
    /// - returns: A `Locked<Self>` value wrapping `self`.
    func locked() -> Locked<Self> { return .init(composable: self) }
}
