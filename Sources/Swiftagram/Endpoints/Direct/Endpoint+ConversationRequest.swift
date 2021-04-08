//
//  Direct+Request.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 27/03/21.
//

import Foundation

public extension Endpoint.Group.Direct.Conversation {
    /// A `struct` defining a wrapper for a conversation request.
    struct Request {
        /// The conversation.
        public let conversation: Endpoint.Group.Direct.Conversation
    }

    /// A wrapper for request endpoints.
    var request: Request {
        .init(conversation: self)
    }
}

public extension Endpoint.Group.Direct.Conversation.Request {
    /// Approve the current conversation request.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func approve() -> Endpoint.Single<Status, Error> {
        conversation.edit("approve/")
    }

    /// Decline the current conversation request.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func decline() -> Endpoint.Single<Status, Error> {
        conversation.edit("reject/")
    }
}
