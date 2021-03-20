//
//  Status.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 31/07/20.
//

import Foundation

/// A `struct` representing a `Status`.
public struct Status: ResponseType {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}
