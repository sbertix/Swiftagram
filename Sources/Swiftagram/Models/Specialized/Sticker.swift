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
                                                                    "additionalConfiguration": \Self.additionalConfiguration]

    /// The identifier.
    public var identifier: String! { self["id"].string() }
    /// The key.
    public var key: String! { self["key"].string() }
    /// Additional configuration types.
    public var additionalConfiguration: [String: Wrapper]? {
        self["additionalConfiguration"].dictionary()?.compactMapValues { $0.optional() }
    }

    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}

// MARK: Constructors.
public extension Sticker {
    /// Create a mension sticker for a given user.
    /// - parameter identifier: A valid user identifier.
    /// - returns: A valid `Sticker`.
    static func mention(_ identifier: String) -> Sticker {
        Sticker(wrapper: ["id": "mention_sticker_vibrant".wrapped,
                          "key": "mentions".wrapped,
                          "displayType": "mention_username".wrapped,
                          "userId": identifier.wrapped,
                          "width": 0.64,
                          "height": 0.125])
            .zIndex(0)
            .center()
            .rotate(by: 0)
            .scale(by: 1)
    }
}

// MARK: Layout.
public extension Sticker {
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
        return .init(wrapper: copy.wrapped)
    }

    /// Center `self` in the middle of the canvas.
    /// - returns: A valid `Sticker`.
    func center() -> Sticker {
        var copy = wrapper().dictionary()!
        copy["x"] = 0.5
        copy["y"] = 0.5
        return .init(wrapper: copy.wrapped)
    }

    /// Rotate `self` by `angle` in degrees.
    /// - parameter angle: A valid `CGFloat`.
    /// - returns: A valid `Sticker`.
    func rotate(by angle: CGFloat) -> Sticker {
        var copy = wrapper().dictionary()!
        copy["rotation"] = Double(angle.truncatingRemainder(dividingBy: 360)).wrapped
        return .init(wrapper: copy.wrapped)
    }

    /// Scale `self` by `factor`.
    func scale(by factor: CGFloat) -> Sticker {
        var copy = wrapper().dictionary()!
        copy["width"] = (Double(factor)*(copy["width"]?.double() ?? 1)).wrapped
        copy["height"] = (Double(factor)*(copy["height"]?.double() ?? 1)).wrapped
        return .init(wrapper: copy.wrapped)
    }
}

// MARK: Request
/*extension Sticker: RequestType {
    /// Adjust `wrapped` to work in a request.
    /// - parameter wrapped: A valid instance of `Self`.
    /// - returns: An optional `Wrapper`.
    public static func request(_ wrapped: Sticker) -> Wrapper? {
        Dictionary(uniqueKeysWithValues: wrapped.wrapper()
                    .dictionary()?
                    .compactMap { key, value -> (String, Wrapper)? in
                        switch key {
                        case "id", "key", "additionalConfiguration": return nil
                        default: return (key.camelCased, value)
                        }
                    } ?? [])
            .wrapped
            .optional()
    }
}

extension Array: RequestType where Element == Sticker {
    /// Adjust `wrapped` to work in a request.
    /// - parameter wrapped: A valid instance of `Self`.
    /// - returns: An optional `Wrapper`.
    public static func request(_ wrapped: [Element]) -> Wrapper? {
        guard !wrapped.isEmpty else { return .none }
        // Group stickers by `key`.
        let groups = Dictionary(grouping: wrapped.compactMap { $0.key == nil ? nil : $0 },
                                by: { $0.key! })
        // Prepare values.
        var results = groups.mapValues { stickers -> Wrapper in
            ["value": (try? stickers.map { Sticker.request($0) }.wrapped.jsonRepresentation()).wrapped,
             "enumerable": true]
        }
        results["story_sticker_ids"] = Set(wrapped.compactMap(\.identifier)).joined(separator: ",").wrapped
        results.merge(wrapped.compactMap(\.additionalConfiguration).reduce([:]) { former, insert in
            var current = former
            current.merge(insert) { lhs, _ in lhs }
            return current
        }) { lhs, _ in lhs }
        // Update one by one.
        if results["mentions"] != nil {
            results["caption"] = ""
            results["reel_mentions"] = results["mensions"]
            results["mas_opt_in"] = "NOT_PROMPTED"
        }
        // Return value.
        return results.wrapped.optional()
    }
}*/
