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
    public var level: Int? { self["z"].int() }
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

    /// Create a slider sticker.
    /// - parameters:
    ///     - question: A valid `String`.
    ///     - emoji: A valid `String` containing a single emoji.
    /// - returns: A valid `Sticker`.
    /// - note: This does not edit the original image, unlike the Instagram client app: it only adds the interactive sticker.
    /// - warning: You can only add one per story. The last one in the `Sequence` will be used.
    static func slider(_ question: String, emoji: String) -> Sticker {
        Sticker(identifier: "slider",
                wrapper: ["question": question.wrapped,
                          "emoji": emoji.wrapped,
                          "viewerVote": 0,
                          "viewerCanVote": false,
                          "sliderVoteCount": 0,
                          "sliderVoteAverage": 0,
                          "backgroundColor": "#ffffff",
                          "textColor": "#000000",
                          "width": 0.64,
                          "height": 0.125])
            .initiate(isSticker: true)
    }

    /// Create a countdown sticker.
    /// - parameters:
    ///     - date: A valid `Date`.
    ///     - event: A valid `String`
    ///     - canBeFollowed: A valid `Bool`. Defaults to `true`.
    /// - returns: A valid `Sticker`.
    /// - note: This does not edit the original image, unlike the Instagram client app: it only adds the interactive sticker.
    /// - warning: You can only add one per story. Tle last one in the `Sequence` will be used.
    static func countdown(to date: Date, event: String, canBeFollowed: Bool = true) -> Sticker {
        Sticker(identifier: "countdown",
                wrapper: ["text": event.wrapped,
                          "endTs": Int(date.timeIntervalSince1970).wrapped,
                          "textColor": "#ffffff",
                          "startBackgroundColor": "#ca2ee1",
                          "endBackgroundColor": "#5eb1ff",
                          "digitColor": "#ffffff",
                          "digitalCardColor": "#1e272e",
                          "followingEnabled": canBeFollowed.wrapped,
                          "width": 0.64,
                          "height": 0.125])
            .initiate(isSticker: true)
    }

    /// Create a question sticker.
    /// - parameter question: A valid `String`.
    /// - returns: A valid `Sticker`.
    /// - note: This does not edit the original image, unlike the Instagram client app: it only adds the interactive sticker.
    /// - warning: You can only add one per story. Tle last one in the `Sequence` will be used.
    static func question(_ question: String) -> Sticker {
        Sticker(identifier: "question",
                wrapper: ["question": question.wrapped,
                          "backgroundColor": "#ffffff",
                          "textColor": "#000000",
                          "profilePicUrl": "",
                          "questionType": "text",
                          "viewerCanInteract": false,
                          "width": 0.64,
                          "height": 0.125])
            .initiate(isSticker: true)
    }

    /// Create a poll sticker.
    /// - parameters:
    ///     - question: A valid `String`.
    ///     - tallies: A sequence of `String`s. **Only the last two will be used.**
    ///     - fontSize: A `CGFloat` between `17.5` and `35`. Defaults to `28`.
    /// - returns: A valid `Sticker`.
    /// - note: This does not edit the original image, unlike the Instagram client app: it only adds the interactive sticker.
    /// - warning: You can only add one per story. Tle last one in the `Sequence` will be used.
    static func poll<S: Sequence>(_ question: String,
                                  tallies: S,
                                  fontSize: CGFloat = 28) -> Sticker where S.Element == String {
        Sticker(identifier: "poll",
                wrapper: ["question": question.wrapped,
                          "viewerVote": 0,
                          "viewerCanVote": true,
                          "tallies": tallies
                            .suffix(2)
                            .map {
                                ["text": $0.wrapped,
                                 "count": 0,
                                 "font_size": fontSize.wrapped]
                            }.wrapped,
                          "width": 0.64,
                          "height": 0.125])
            .initiate(isSticker: true)
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
        copy["z"] = index.wrapped
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

    /// Set a relative position for `self`.
    /// - parameters:
    ///     - x: An optional `CGFloat`. Defaults to `nil`, meaning `x` is not changed.
    ///     - y: An optional `CGFloat`. Defaults to `nil`, meaning `y` is not changed.
    /// - returns: A valid `Sticker`.
    func position(x: CGFloat? = nil, y: CGFloat? = nil) -> Sticker {
        var copy = wrapper().dictionary()!
        if let x = x { copy["x"] = x.wrapped }
        if let y = y { copy["y"] = y.wrapped }
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
    /// - parameter factor: A valid `CGFloat`.
    /// - returns: A valid `Sticker`.
    func scale(by factor: CGFloat) -> Sticker {
        var copy = wrapper().dictionary()!
        copy["width"] = (Double(factor)*(copy["width"]?.double() ?? 0.5)).wrapped
        copy["height"] = (Double(factor)*(copy["height"]?.double() ?? 0.5)).wrapped
        return .init(identifier: identifier, wrapper: copy.wrapped)
    }

    /// Set relative size.
    /// - parameters:
    ///     - width: An optional `CGFloat`. Defaults to `nil`, meaning `width` is not changed.
    ///     - height: An optional `CGFloat`. Defaults to `nil`, meaning `height` is not changed.
    /// - returns: A valid `Sticker`.
    func size(width: CGFloat? = nil, height: CGFloat? = nil) -> Sticker {
        var copy = wrapper().dictionary()!
        if let width = width { copy["width"] = width.wrapped }
        if let height = height { copy["height"] = height.wrapped }
        return .init(identifier: identifier, wrapper: copy.wrapped)
    }
}

public extension Sequence where Element == Sticker {
    /// Transform into a dictionary of `Wrapper`s.
    /// - returns: A valid `Dictionary`.
    func request() -> [String: Wrapper] {
        var ids: [String] = []
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
        // Add only the last slider.
        if let sliders = split["slider"]?.suffix(1), !sliders.isEmpty {
            response["story_sliders"] = (try? sliders.compactMap { $0.wrapper().camelCased().optional() }.wrapped.jsonRepresentation())?.wrapped
            ids += sliders.compactMap { $0["emoji"].string().flatMap { "emoji_slider_"+$0 }}
        }
        // Add only the last countdown.
        if let countdowns = split["countdown"]?.suffix(1), !countdowns.isEmpty {
            response["story_countdowns"] = (try? countdowns.compactMap { $0.wrapper().camelCased().optional() }.wrapped.jsonRepresentation())?.wrapped
            ids.append("countdown_sticker_time")
        }
        // Add only the last question.
        if let questions = split["question"]?.suffix(1), !questions.isEmpty {
            response["story_questions"] = (try? questions.compactMap { $0.wrapper().camelCased().optional() }.wrapped.jsonRepresentation())?.wrapped
            ids.append("question_sticker_ama")
        }
        // Add only the last poll.
        if let polls = split["poll"]?.suffix(1), !polls.isEmpty {
            response["story_polls"] = (try? polls.compactMap { $0.wrapper().camelCased().optional() }.wrapped.jsonRepresentation())?.wrapped
            response["internal_features"] = "polling_sticker"
            response["mas_opt_in"] = "NOT_PROMPTED"
        }
        // Return response.
        response["story_sticker_ids"] = ids.joined(separator: ",").wrapped
        return response
    }
}
