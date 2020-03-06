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
    /// All the path components.
    internal let components: [String]
    /// Compute the `URL`.
    public var url: URL? { URL(string: components.joined(separator: "/")) }
    
    // MARK: Lifecycle
    /// Init.
    /// - parameter components: A `Collection` of `String`s, forming a valid `https` address, when joined together using `/`.
    public init(components: [String]) { self.components = components }
    
    // MARK: Composition
    /// An `Endpoint` pointing to `api/v1`.
    public static var version1: Endpoint { return .init(components: ["https://i.instagram.com/api/v1"]) }
    /// An `Endpoint`pointing to `api/v2`.
    public static var version2: Endpoint { return .init(components: ["https://i.instagram.com/api/v2"]) }
    /// An `Endpoint` pointing to the Instagram homepage.
    public static var generic: Endpoint { return .init(components: ["https://www.instagram.com"]) }

    /// Append `item`.
    public func appending<Item>(_ item: Item) -> Endpoint where Item: LosslessStringConvertible {
        return .init(components: components+[String(item)])
    }
    /// Append `item`.
    public func appending<Item>(_ item: Item) -> Endpoint where Item: CustomStringConvertible {
        return .init(components: components+[item.description])
    }
    /// Append `component`.
    public subscript(dynamicMember component: String) -> Endpoint {
        return .init(components: components+[component])
    }
}
