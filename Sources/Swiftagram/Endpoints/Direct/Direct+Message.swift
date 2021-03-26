//
//  Direct+Message.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 25/03/21.
//

import Foundation

public extension Endpoint.Direct.Conversation {
    /// A `struct` defining a wrapper for a specific message.
    struct Message: Parent {
        /// The conversation.
        let conversation: Endpoint.Direct.Conversation
        /// The identifier.
        let identifier: String
    }

    /// A wrapper for message endpoints.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Message`.
    func message(_ identifier: String) -> Message {
        .init(conversation: self, identifier: identifier)
    }
}

extension Request {
    /// A specific message base request.
    ///
    /// - parameter message: A valid `Message`.
    static func directMessage(_ message: Endpoint.Direct.Conversation.Message) -> Request {
        Request.directThread(message.conversation).items.path(appending: message.identifier)
    }
}

public extension Endpoint.Direct.Conversation.Message {
    /// Delete the current message.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    func delete() -> Endpoint.Disposable<Status, Error> {
        disposable(at: Request.directMessage(self).path(appending: "delete/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString])
        }
    }

    /// Mark the current message as watched.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    func open() -> Endpoint.Disposable<Status, Error> {
        disposable(at: Request.directMessage(self).path(appending: "seen/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString,
                                "use_unified_inbox": "true",
                                "action": "mark_seen",
                                "thread_id": self.conversation.identifier,
                                "item_id": self.identifier])
        }
    }
}
