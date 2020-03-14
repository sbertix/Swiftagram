//
//  Expecting.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `protocol` defining an expected `Response` type.
public protocol Expecting {
    /// An associated `Response` type.
    associatedtype Response: DataMappable
}
