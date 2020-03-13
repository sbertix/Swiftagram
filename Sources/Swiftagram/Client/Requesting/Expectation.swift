//
//  Expectation.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `struct` for changing a request expected `Response`.
public struct Expectation<Requestable: Swiftagram.Requestable, Response: DataMappable>: Swiftagram.Requestable {
    /// A valid `Requestable`.
    internal var requestable: Requestable
}

extension Expectation: Composable where Requestable: Swiftagram.Composable { }
extension Expectation: WrappedComposable where Requestable: Swiftagram.Composable {
    /// A valid `Composable`.
    public var composable: Requestable {
        get { return requestable }
        set { requestable = newValue }
    }
}
