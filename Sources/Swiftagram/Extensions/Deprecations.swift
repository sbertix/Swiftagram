//
//  Deprecations.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 17/08/2020.
//

import Foundation

@available(*, deprecated, renamed: "Conversation")
public typealias Thread = Conversation

@available(*, deprecated, renamed: "Conversation.Unit")
public typealias ThreadUnit = Conversation.Unit

@available(*, deprecated, renamed: "Conversation.Collection")
public typealias ThreadCollection = Conversation.Collection

@available(*, deprecated, renamed: "Recipient")
public typealias ThreadRecipient = Recipient

@available(*, deprecated, renamed: "Recipient.Collection")
public typealias ThreadRecipientCollection = Recipient.Collection

@available(*, deprecated, renamed: "Comment.Collection")
public typealias CommentCollection = Comment.Collection

@available(*, deprecated, renamed: "Conversation.Unit")
public typealias ConversationUnit = Conversation.Unit

@available(*, deprecated, renamed: "Conversation.Collection")
public typealias ConversationCollection = Conversation.Collection

@available(*, deprecated, renamed: "Friendship.Collection")
public typealias FriendshipCollection = Friendship.Collection

@available(*, deprecated, renamed: "Location.Unit")
public typealias LocationUnit = Location.Unit

@available(*, deprecated, renamed: "Location.Collection")
public typealias LocationCollection = Location.Collection

@available(*, deprecated, renamed: "Media.Unit")
public typealias MediaUnit = Media.Unit

@available(*, deprecated, renamed: "Media.Collection")
public typealias MediaCollection = Media.Collection

@available(*, deprecated, renamed: "Recipient.Collection")
public typealias RecipientCollection = Recipient.Collection

@available(*, deprecated, renamed: "TrayItem.Unit")
public typealias TrayItemUnit = TrayItem.Unit

@available(*, deprecated, renamed: "TrayItem.Collection")
public typealias TrayItemCollection = TrayItem.Collection

@available(*, deprecated, renamed: "User.Unit")
public typealias UserUnit = User.Unit

@available(*, deprecated, renamed: "User.Collection")
public typealias UserCollection = User.Collection

public extension Endpoint.Media.Posts {
    /// All posts for user matching `identifier`.
    /// - parameters:
    ///     - identifier: A `String` holding reference to a valid user identifier.
    ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
    /// - warning: This method will be removed in `4.2.0`.
    @available(*, deprecated, renamed: "owned")
    static func by(_ identifier: String, startingAt page: String? = nil) -> Endpoint.Paginated<Media.Collection> {
        owned(by: identifier, startingAt: page)
    }
}

public extension Endpoint.Media.Stories {
    /// All available stories for user matching `identifier`.
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    /// - warning: This method will be removed in `4.2.0`.
    @available(*, deprecated, renamed: "owned")
    static func by(_ identifier: String) -> Endpoint.Disposable<TrayItem.Unit> {
        owned(by: identifier)
    }
}
