//
//  Verification.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `struct` representing verification methods.
public struct Verification: Hashable {
    /// A `string` describing the label.
    public var label: String
    /// The related value.
    internal var value: String

    /// Init with `Response`.
    /// - parameter response: A valid `Response`.
    internal init?(response: Response) {
        guard let label = response.label.string(), let value = response.value.string() else { return nil }
        self.label = label
        self.value = value
    }
}
