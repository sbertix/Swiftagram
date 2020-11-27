//
//  Deprecations.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 17/08/2020.
//

import Foundation

public extension User {
    /// The friendship status with the logged in user.
    @available(*, deprecated, message: "Instagram changes mean this will always return `nil`; removing definition in `4.3.0`")
    var friendship: Friendship? {
        (self["friendship"].optional()
            ?? self["friendshipStatus"].optional())
            .flatMap(Friendship.init)
    }
}

public extension Endpoint.Direct {
    /// All threads.
    /// 
    /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
    @available(*, deprecated, renamed: "inbox(startingAt:)", message: "removing definition in `4.3.0`")
    static func threads(startingAt page: String? = nil) -> Endpoint.Paginated<Conversation.Collection> {
        inbox(startingAt: page)
    }

    /// All pending threads.
    ///
    /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
    @available(*, deprecated, renamed: "pendingInbox(startingAt:)", message: "removing definition in `4.3.0`")
    static func pendingThreads(startingAt page: String? = nil) -> Endpoint.Paginated<Conversation.Collection> {
        pendingInbox(startingAt: page)
    }

    /// A thread matching `identifier`.
    ///
    /// - parameters:
    ///     - identifier: A `String` holding reference to a valid thread identifier.
    ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
    @available(*, deprecated, renamed: "conversation(matching:startingAt:)", message: "removing definition in `4.3.0`")
    static func thread(matching identifier: String, startingAt page: String? = nil) -> Endpoint.Paginated<Conversation.Unit> {
        conversation(matching: identifier, startingAt: page)
    }
}

public extension Secret {
    /// A `String` representing the logged in user identifier.
    @available(*, deprecated, renamed: "identifier")
    var id: String { cookies.first(where: { $0.name == "ds_user_id" })!.value }

    /// An `HTTPCookie` holding reference to the cross site request forgery token.
    @available(*, unavailable, message: "removed for security concerns")
    var crossSiteRequestForgery: HTTPCookie! { fatalError("Unavailable") }

    /// An `HTTPCookie` holding reference to the session identifier.
    @available(*, unavailable, message: "removed for security concerns")
    var session: HTTPCookie! { fatalError("Unavailable") }
}

/// An `enum` holding reference to custom User Agents.
@available(*, unavailable, message: "use custom `Client`s instead")
public enum UserAgent {
    /// Defaults to `Device.default.browserUserAgent`.
    case `default`
    /// Tied to a specific iOS version, e.g. `13_4_1`.
    /// - warning: You won't be able to use encrypted endpoints (e.g. `Endpoint.Friendship.follow`).
    case iOS(version: String)
    /// An entirely custom user agent.
    /// - warning: You won't be abled to use encrypted endpoints (e.g. `Endpoint.Friendship.follow`), unless the user agent is of an Android device.
    case custom(String)
    /// Tied to the current iOS version.
    /// - warning: You won't be able to use encrypted endpoints (e.g. `Endpoint.Friendship.follow`).
    case current
}

@available(iOS 11.0, macOS 10.13, macCatalyst 13.0, *)
public extension WebViewAuthenticator {
    /// Set a custom User Agent.
    ///
    /// - parameter userAgent: A valid `UserAgent`.
    /// - returns: `self`.
    /// - warning: Custom User Agents are not guaranteed to work.
    @available(*, unavailable, message: "please create a custom `Client` and pass it to your `WebViewAuthenticator`.")
    func userAgent(_ userAgent: UserAgent) -> WebViewAuthenticator<Storage> { fatalError("Unavailable") }

    /// Set a custom User Agent.
    ///
    /// - parameter userAgent: A `String` representing a valid User Agent.
    /// - returns: `self`.
    /// - warning: Custom User Agents are not guaranteed to work.
    @available(*, unavailable, message: "please create a custom `Client` and pass it to your `WebViewAuthenticator`.")
    func userAgent(_ userAgent: String) -> WebViewAuthenticator<Storage> { fatalError("Unavailable") }
}
