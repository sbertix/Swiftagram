//
//  UserTag.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 01/08/20.
//

import CoreGraphics
import Foundation

import ComposableRequest

/// A `struct` representing a `UserTag`.
public struct UserTag: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The  user identifier.
    public var identifier: String! { self["user_id"].string(converting: true) }
    /// The x relative position inside the canvas.
    public var x: CGFloat! { self["position"][0].double().flatMap(CGFloat.init) }
    /// The y relative position inside the canvas.
    public var y: CGFloat! { self["position"][1].double().flatMap(CGFloat.init) }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// Init.
    /// - parameters:
    ///     - x: A `CGFloat`. Values are adjusted to fall between `0.001` and `0.999`.
    ///     - y: A `CGFloat`. Values are adjusted to fall between `0.001` and `0.999`.
    ///     - identifier: A `String` representing a user identifier.
    public init(x: CGFloat, y: CGFloat, identifier: String) {
        let response: Wrapper = [
            "position": [Wrapper(floatLiteral: max(0.001, min(Double(x), 0.999))),
                         Wrapper(floatLiteral: max(0.001, min(Double(y), 0.999)))],
            "user_id": Wrapper(stringLiteral: identifier)
        ]
        self.init(wrapper: response)
    }

    /// The debug description.
    public var debugDescription: String {
        ["UserTag(",
         ["identifier": identifier as Any,
          "x": x as Any,
          "y": y as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
