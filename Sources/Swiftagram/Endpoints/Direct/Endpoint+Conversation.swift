//
//  Endpoint+Conversation.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 25/03/21.
//

import Foundation

public extension Endpoint.Group.Direct {
    /// A `class` defining a wrapper for a specific conversation.
    final class Conversation {
        /// The identifier.
        public let identifier: String

        /// Init.
        ///
        /// - parameter identifier: A valid `String`.
        init(identifier: String) {
            self.identifier = identifier
        }
    }

    /// A wrapper for conversation endpoints.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Conversation`.
    func conversation(_ identifier: String) -> Conversation {
        .init(identifier: identifier)
    }

    /// A summary for the current conversation.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func conversation(_ identifier: String) -> Endpoint.Single<AnyDecodable> {
        conversation(identifier).summary // Swiftagram.Conversation.Unit
    }
}

extension Swiftagram.Request {
    /// A specific thread bease request.
    ///
    /// - parameter conversation: A valid `Conversation` identifier.
    static func directThread(_ conversation: String) -> Request {
        Request.directThreads.path(appending: conversation)
    }
}

public extension Endpoint.Group.Direct.Conversation {
    /// A summary for the current conversation.
    ///
    /// - note: Use `Endpoint.Direct.conversation(_:)` instead.
    internal var summary: Endpoint.Single<Conversation.Unit> {
        .init { secret in
            
        }
    }

    /// Paginate all messages in the conversation.
    var messages: Endpoint.Paginated<String?, Conversation.Unit> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Swiftagram.Request.directThread(self.identifier)
                    .header(appending: secret.header)
                    .query(appending: ["visual_message_return_type": "unseen",
                                       "direction": $0.flatMap { _ in "older" },
                                       "cursor": $0,
                                       "limit": "20"])
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Swiftagram.Conversation.Unit.init)
            }
            .requested(by: requester)
        }
    }

    /// Delete the current conversation.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func delete() -> Endpoint.Single<Status> {
        edit("hide/", body: ["use_unified_inbox": "true"])
    }

    /// Leave the current conversation.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func leave() -> Endpoint.Single<Status> {
        edit("leave/")
    }

    /// Mute the current conversation.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func mute() -> Endpoint.Single<Status> {
        edit("mute/")
    }

    /// Send a message in the current conversation.
    ///
    /// - parameter text: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func send(_ text: String) -> Endpoint.Single<Wrapper> {
        .init { secret, requester in
            // Prepare the body.
            var method = "text"
            var body: [String: String] = ["thread_ids": "[" + self.identifier + "]"]
            // Prepare the detector.
            let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector?.matches(in: text,
                                            options: [],
                                            range: .init(location: 0, length: text.utf16.count))
                .compactMap { Range($0.range, in: text).flatMap { "\"" + text[$0] + "\"" } } ?? []
            if !matches.isEmpty {
                method = "link"
                body["link_text"] = text
                body["link_urls"] = "[" + matches.joined(separator: ",") + "]"
            } else {
                body["text"] = text
            }
            // Prepare the request.
            return Swiftagram.Request.directThreads
                .broadcast.path(appending: method)
                .path(appending: "/")
                .header(appending: secret.header)
                .body(appending: body)
                .body(appending: ["_csrftoken": secret["csrftoken"],
                                  "_uuid": secret.client.device.identifier.uuidString,
                                  "device_id": secret.client.device.instagramIdentifier,
                                  "client_context": UUID().uuidString,
                                  "action": "send_item"])
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .requested(by: requester)
        }
    }

    /// Update the title for the current conversation.
    ///
    /// - parameter title: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func title(_ title: String) -> Endpoint.Single<Status> {
        edit("update_title/", body: ["title": title])
    }

    /// Unmute the current conversation.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unmute() -> Endpoint.Single<Status> {
        edit("unmute/")
    }
}

extension Endpoint.Group.Direct.Conversation {
    /// Edit the conversation.
    ///
    /// - parameters:
    ///     - endpoint: A valid `String`.
    ///     - body: A valid dictionary of `String`s.
    /// - returns: A valid `Endpoint.Single`.
    func edit(_ endpoint: String, body: [String: String] = [:]) -> Endpoint.Single<Status> {
        .init { secret, requester in
            Swiftagram.Request.directThread(self.identifier)
                .path(appending: endpoint)
                .header(appending: secret.header)
                .body(appending: ["_csrftoken": secret["csrftoken"],
                                  "_uuid": secret.client.device.identifier.uuidString])
                .body(appending: body)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Status.init)
                .requested(by: requester)
        }
    }
}
