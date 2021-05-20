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
    /// - parameter message: A valid `Message`.
    static func directMessage(_ message: Endpoint.Group.Direct.Conversation.Message) -> Request {
        Swiftagram.Request.directThread(message.conversation).items.path(appending: message.identifier)
    }
}

public extension Endpoint.Group.Direct.Conversation.Message {
    /// Delete the current message.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func delete() -> Endpoint.Single<Status, Error> {
        .init { secret, session in
            Deferred {
                Request.directMessage(self)
                    .path(appending: "delete/")
                    .header(appending: secret.header)
                    .body(appending: ["_csrftoken": secret["csrftoken"],
                                      "_uuid": secret.client.device.identifier.uuidString])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Status.init)
            }
            .replaceFailingWithError()
        }
    }

    /// Mark the current message as watched.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func open() -> Endpoint.Single<Status, Error> {
        .init { secret, session in
            Deferred {
                Request.directMessage(self)
                    .path(appending: "seen/")
                    .header(appending: secret.header)
                    .body(appending: ["_csrftoken": secret["csrftoken"],
                                      "_uuid": secret.client.device.identifier.uuidString,
                                      "use_unified_inbox": "true",
                                      "action": "mark_seen",
                                      "thread_id": self.conversation.identifier,
                                      "item_id": self.identifier])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Status.init)
            }
            .replaceFailingWithError()
        }
    }
}
