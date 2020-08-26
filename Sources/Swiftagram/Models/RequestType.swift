//
//  RequestType.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/08/20.
//

import Foundation

import ComposableRequest

/// A `protocol` transforming a `Wrapped` to be used in a request.
public protocol RequestType: Wrapped {
    /// Adjust `wrapped` to work in a request.
    /// - parameter wrapped: A valid instance of `Self`.
    /// - returns: An optional `Wrapper`.
    static func request(_ wrapped: Self) -> Wrapper?
}
