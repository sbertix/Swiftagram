//
//  Direct+Message.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 25/03/21.
//

import Foundation

public extension Endpoint.Group.Direct.Conversation {
    /// A `class` defining a wrapper for a specific message.
    final class Message {
        /// The conversation.
        public let conversation: Endpoint.Group.Direct.Conversation
        /// The identifier.
        public let identifier: String

        /// Init.
        ///
        /// - parameters:
        ///     - conversation: A valid `Endpoint.Group.Direct.Conversation`.
        ///     - identifier: A valid `String`.
        init(conversation: Endpoint.Group.Direct.Conversation,
             identifier: String) {
            self.conversation = conversation
            self.identifier = identifier
        }
    }

    /// A wrapper for message endpoints.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Message`.
    func message(_ identifier: String) -> Message {
        .init(conversation: self, identifier: identifier)
    }
}

extension Swiftagram.Request {
    /// A specific message base request.
    ///
    /// - parameters:
    ///     - message: A valid `Message` identifier.
    ///     - conversation: A valid `Conversation` identifier.
    static func directMessage(_ message: String,
                              in conversation: String) -> Request {
        Swiftagram.Request.directThread(conversation).items.path(appending: message)
    }
}

public extension Endpoint.Group.Direct.Conversation.Message {
    /// Delete the current message.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func delete() -> Endpoint.Single<Status> {
        .init { secret, requester in
            Request.directMessage(self.identifier, in: self.conversation.identifier)
                .path(appending: "delete/")
                .header(appending: secret.header)
                .body(appending: ["_csrftoken": secret["csrftoken"],
                                  "_uuid": secret.client.device.identifier.uuidString])
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Status.init)
                .requested(by: requester)
        }
    }

    /// Mark the current message as watched.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func open() -> Endpoint.Single<Status> {
        .init { secret, requester in
            Request.directMessage(self.identifier, in: self.conversation.identifier)
                .path(appending: "seen/")
                .header(appending: secret.header)
                .body(appending: ["_csrftoken": secret["csrftoken"],
                                  "_uuid": secret.client.device.identifier.uuidString,
                                  "use_unified_inbox": "true",
                                  "action": "mark_seen",
                                  "thread_id": self.conversation.identifier,
                                  "item_id": self.identifier])
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Status.init)
                .requested(by: requester)
        }
    }
}
