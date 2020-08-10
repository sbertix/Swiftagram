//
//  ThreadRecipient.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/08/20.
//

import Foundation

import ComposableRequest

/// An `enum` holding reference to either a `User` or a `Thread` instance.
public enum ThreadRecipient: Wrapped {
    /// A valid `User`.
    case user(User)
    /// A valid `Thread`.
    case thread(Thread)
    /// Neither, meaning something went wrong.
    case error(Wrapper)

    /// The underlying `Response`.
    public var wrapper: () -> Wrapper {
        switch self {
        case .user(let user): return user.wrapper
        case .thread(let thread): return thread.wrapper
        case .error(let error): return { error }
        }
    }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        let response = wrapper()
        switch response.dictionary()?.keys.first {
        case "thread": self = .thread(.init(wrapper: response["thread"]))
        case "user": self = .user(.init(wrapper: response["user"]))
        default: self = .error(response)
        }
    }
}

/// A `struct` representing a `ThreadRecipient` collection.
public struct ThreadRecipientCollection: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The recipients.
    public var recipients: [ThreadRecipient]? { self["rankedRecipients"].array()?.map(ThreadRecipient.init) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["ThreadRecipientCollection(",
         ["recipients": recipients as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
