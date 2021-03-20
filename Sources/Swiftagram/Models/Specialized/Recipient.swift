//
//  Recipient.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/08/20.
//

import Foundation

/// An `enum` holding reference to either a `User` or a `Conversation` instance.
public enum Recipient: Wrapped {
    /// A valid `User`.
    case user(User)
    /// A valid `Thread`.
    case thread(Conversation)
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

public extension Recipient {
    /// A `struct` representing a `Recipient` collection.
    struct Collection: ResponseType, Paginatable {
        /// The associated offset type.
        public typealias Offset = String?

        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The recipients.
        public var recipients: [Recipient]? { self["rankedRecipients"].array()?.map(Recipient.init) }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }
}
