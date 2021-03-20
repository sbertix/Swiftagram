//
//  UserTag.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 01/08/20.
//

import CoreGraphics
import Foundation

/// A `struct` representing a `UserTag`.
public struct UserTag: ReflectedType {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["identifier": \Self.identifier,
                                                                    "x": \Self.x,
                                                                    "y": \Self.y]

    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The  user identifier.
    public var identifier: String! { self["userId"].string(converting: true) }
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
        self.init(wrapper: ["position": [max(0.001, min(Double(x), 0.999)).wrapped,
                                         max(0.001, min(Double(y), 0.999)).wrapped],
                            "userId": identifier.wrapped])
    }
}
