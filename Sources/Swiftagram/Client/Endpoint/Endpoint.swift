//
//  Endpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `struct` defining all possible `Endpoint`s.
public struct Endpoint {
    // MARK: Composition
    /// An `Endpoint` pointing to `api/v1`.
    public static var version1: ComposableRequest { return .init(url: URL(string: "https://i.instagram.com/api/v1")!) }
    /// An `Endpoint`pointing to `api/v2`.
    public static var version2: ComposableRequest { return .init(url: URL(string: "https://i.instagram.com/api/v2")!) }
    /// An `Endpoint` pointing to the Instagram homepage.
    public static var generic: ComposableRequest { return .init(url: URL(string: "https://www.instagram.com")!) }
}
