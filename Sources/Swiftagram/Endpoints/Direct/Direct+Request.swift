//
//  Direct+Request.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 27/03/21.
//

import Foundation

public extension Endpoint.Direct.Conversation {
    /// A `struct` defining a wrapper for a conversation request.
    struct Request {
        /// The conversation.
        public let conversation: Endpoint.Direct.Conversation
    }

    /// A wrapper for request endpoints.
    var request: Request {
        .init(conversation: self)
    }
}

public extension Endpoint.Direct.Conversation.Request {
    /// Approve the current conversation request.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func approve() -> Endpoint.Disposable<Status, Error> {
        conversation.edit("approve/")
    }

    /// Decline the current conversation request.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func decline() -> Endpoint.Disposable<Status, Error> {
        conversation.edit("reject/")
    }
}
