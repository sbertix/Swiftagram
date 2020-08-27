//
//  Sticker.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/08/20.
//

import CoreGraphics
import Foundation

import ComposableRequest

/// A `struct` holding reference to a story sticker.
public struct Sticker: ReflectedType {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["identifier": \Self.identifier,
                                                                    "level": \Self.level,
                                                                    "offset": \Self.offset,
                                                                    "rotation": \Self.rotation]

    /// The identifier.
    public var identifier: String
    /// The relative position.
    public var offset: CGPoint? {
        guard let x = self["x"].double(), let y = self["y"].double() else { return nil }
        return .init(x: x, y: y)
    }
    /// The zIndex.
    public var level: Int? { self["zIndex"].int() }
    /// The rotation in degrees.
    public var rotation: CGFloat? { self["rotation"].double().flatMap(CGFloat.init) }

    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
        self.identifier = "unknown"
    }

    /// Init.
    /// - parameters:
    ///     - identifier: A valid `String`.
    ///     - wrapper: A valid `Wrapper`.
    public init(identifier: String, wrapper: Wrapper) {
        self.init(wrapper: wrapper)
        self.identifier = identifier
    }
}

// MARK: Constructors.
public extension Sticker {
    /// Create a mension sticker for a given user.
    /// - parameter identifier: A valid user identifier.
    /// - returns: A valid `Sticker`.
    /// - note: This only creates a tappable area linking to the appropriate profile. Picture editing is done client side.
    static func mention(_ identfier: String) -> Sticker {
        Sticker(identifier: "mention",
                wrapper: ["userId": identfier.wrapped,
                          "width": 0.64,
                          "height": 0.125])
            .initiate()
    }

    /// Create an hashtag sticker.
    /// - parameter tag: A valid tag.
    /// - returns: A valid `Sticker`.
    /// - note: This only creates a tappable area linking to the appropriate profile. Picture editing is done client side.
    static func tag(_ tag: String) -> Sticker {
        Sticker(identifier: "tag",
                wrapper: ["tagName": String(tag.unicodeScalars.filter(CharacterSet.alphanumerics.contains)).wrapped,
                          "width": 0.64,
                          "height": 0.125])
            .initiate()
    }

    /// Create a location sticker.
    /// - parameter identifier: A valid location identfiier.
    /// - returns: A valid `Sticker`.
    /// - note: This only creates a tappable area linking to the appropriate profile. Picture editing is done client side.
    static func location(_ identifier: String) -> Sticker {
        Sticker(identifier: "location",
                wrapper: ["locationId": identifier.wrapped,
                          "width": 0.64,
                          "height": 0.125])
            .initiate()
    }
}

// MARK: Layout.
public extension Sticker {
    /// Set all initial values.
    /// - parameters:
    ///     - isSticker: A valid `Bool`. Defaults to `false`.
    ///     - useCustomTitle: A valid `Bool`. Defaults to `false`.
    /// - returns: A valid `Sticker`.
    private func initiate(isSticker: Bool = false, useCustomTitle: Bool = false) -> Sticker {
        var copy = center()
            .rotate(by: 0)
            .scale(by: 1)
            .zIndex(0)
            .wrapper()
            .dictionary()!
        copy["isSticker"] = isSticker.wrapped
        copy["useCustomTitle"] = useCustomTitle.wrapped
        return .init(identifier: identifier, wrapper: copy.wrapped)
    }

    /// Set a new `zIndex` to `self`.
    /// - parameter index: A valid `Int`.
    /// - returns: A valid `Sticker`.
    func zIndex(_ index: Int) -> Sticker {
        var copy = wrapper().dictionary()!
        copy["zIndex"] = index.wrapped
        return .init(wrapper: copy.wrapped)
    }

    /// Set a relative position for `self`.
    /// - parameter position: A valid `CGPoint`.
    /// - returns: A valid `Sticker`.
    func position(_ position: CGPoint) -> Sticker {
        var copy = wrapper().dictionary()!
        copy["x"] = Double(position.x).wrapped
        copy["y"] = Double(position.y).wrapped
        return .init(identifier: identifier, wrapper: copy.wrapped)
    }

    /// Center `self` in the middle of the canvas.
    /// - returns: A valid `Sticker`.
    func center() -> Sticker {
        var copy = wrapper().dictionary()!
        copy["x"] = 0.5
        copy["y"] = 0.5
        return .init(identifier: identifier, wrapper: copy.wrapped)
    }

    /// Rotate `self` by `angle` in degrees.
    /// - parameter angle: A valid `CGFloat`.
    /// - returns: A valid `Sticker`.
    func rotate(by angle: CGFloat) -> Sticker {
        var copy = wrapper().dictionary()!
        copy["rotation"] = Double(angle.truncatingRemainder(dividingBy: 360)).wrapped
        return .init(identifier: identifier, wrapper: copy.wrapped)
    }

    /// Scale `self` by `factor`.
    func scale(by factor: CGFloat) -> Sticker {
        var copy = wrapper().dictionary()!
        copy["width"] = (Double(factor)*(copy["width"]?.double() ?? 0.5)).wrapped
        copy["height"] = (Double(factor)*(copy["height"]?.double() ?? 0.5)).wrapped
        return .init(identifier: identifier, wrapper: copy.wrapped)
    }
}

public extension Sequence where Element == Sticker {
    /// Transform into a dictionary of `Wrapper`s.
    /// - returns: A valid `Dictionary`.
    func request() -> [String: Wrapper] {
        var response: [String: Wrapper] = [:]
        let split = Dictionary(grouping: self) { $0.identifier }
        // Check for mentions.
        if let mentions = split["mention"] {
            response["reel_mentions"] = (try? mentions.compactMap { $0.wrapper().camelCased().optional() }.wrapped.jsonRepresentation())?.wrapped
            response["mentions"] = response["reel_mentions"]
            response["caption"] = ""
            response["mas_opt_in"] = "NOT_PROMPTED"
        }
        // Add tags.
        if let tags = split["tag"] {
            response["story_hashtags"] = (try? tags.compactMap { $0.wrapper().camelCased().optional() }.wrapped.jsonRepresentation())?.wrapped
            response["caption"] = tags.compactMap { $0["tagName"].string() }.joined(separator: " ").wrapped
            response["mas_opt_in"] = "NOT_PROMPTED"
        }
        // Add locations.
        if let locations = split["location"] {
            response["story_locations"] = (try? locations.compactMap { $0.wrapper().camelCased().optional() }.wrapped.jsonRepresentation())?.wrapped
            response["mas_opt_in"] = "NOT_PROMPTED"
        }
        // Return response.
        return response
    }
}
