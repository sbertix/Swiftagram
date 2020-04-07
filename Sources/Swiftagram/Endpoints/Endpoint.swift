//
//  Endpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import ComposableRequest
import Foundation

/// A `struct` defining all possible `Endpoint`s.
public struct Endpoint {
    // MARK: Composition
    /// An `Endpoint` pointing to `api/v1`.
    public static var version1: Request { return .init(URL(string: "https://i.instagram.com/api/v1")!) }
    /// An `Endpoint` pointing to the Instagram homepage.
    public static var generic: Request { return .init(URL(string: "https://www.instagram.com")!) }
}
