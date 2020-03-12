//
//  Secreted.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 12/03/2020.
//

import Foundation

/**
   A `struct` describing a `Requestable` requiring a `Secret`.

   ## Usage
   ```swift
   let locked = /* a locked request */
   let secret = /* a valid secret */
   let request = locked.authenticating(with: secret)
   ```
*/
@dynamicMemberLookup
public struct Secreted<Requestable: Swiftagram.Requestable>: Swiftagram.Requestable {
    /// A valid `Requestable`.
    public let endpoint: Requestable
    
    // MARK: Resolve
    /// Append `headerFields` for `secret`.
    /// - parameter secret: A valid `Secret`.
    public func authenticating(with secret: Secret) -> Requestable {
        return endpoint.headerFields(secret.headerFields)
    }
    
    // MARK: Requestable
    /// Compute the `URLRequest`.
    public func request() -> URLRequest? { return endpoint.request() }
    
    /// Append `item` to `endpoint`.
    /// - parameter item: A `String`.
    public func wrap(_ item: String) -> Secreted<Requestable> {
        return .init(endpoint: endpoint.wrap(item))
    }

    /// Append `component` to `endpoint`.
    /// - parameter component: A `String`.
    public subscript(dynamicMember component: String) -> Secreted<Requestable> {
        return wrap(component)
    }

    /// Append `body` to `endpoint`.
    /// - parameter body: An optional `Dictionary` of optional `String`s.
    public func body(_ body: [String: String?]?) -> Secreted<Requestable> {
        return .init(endpoint: endpoint.body(body))
    }

    /// Append `queries` to `endpoint`.
    /// - parameter query: An optional `Dictionary` of optional `String`s.
    public func query(_ queries: [String: String?]?) -> Secreted<Requestable> {
        return .init(endpoint: endpoint.query(queries))
    }

    /// Append `headerFields` to `endpoint`.
    /// - parameter headerFields: An optional `Dictionary` of optional `String`s.
    public func headerFields(_ headerFields: [String: String]?) -> Secreted<Requestable> {
        return .init(endpoint: endpoint.headerFields(headerFields))
    }

    /// Set `method` to `endpoint`.
    /// - parameter method: An `Requestable.Method`.
    public func method(_ method: Endpoint.Method) -> Secreted<Requestable> {
        return .init(endpoint: endpoint.method(method))
    }
}

