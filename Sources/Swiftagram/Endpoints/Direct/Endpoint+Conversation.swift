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
    func conversation(_ identifier: String) -> Endpoint.Single<Swiftagram.Conversation.Unit, Error> {
        conversation(identifier).summary
    }
}

extension Swiftagram.Request {
    /// A specific thread bease request.
    ///
    /// - parameter conversation: A valid `Conversation`.
    static func directThread(_ conversation: Endpoint.Group.Direct.Conversation) -> Request {
        Request.directThreads.path(appending: conversation.identifier)
    }
}

public extension Endpoint.Group.Direct.Conversation {
    /// A summary for the current conversation.
    ///
    /// - note: Use `Endpoint.Direct.conversation(_:)` instead.
    internal var summary: Endpoint.Single<Conversation.Unit, Error> {
        .init { secret, session in self.messages.unlock(with: secret).session(session).pages(1) }
    }

    /// Paginate all messages in the conversation.
    var messages: Endpoint.Paginated<Conversation.Unit, String?, Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Swiftagram.Request.directThread(self)
                    .header(appending: secret.header)
                    .query(appending: ["visual_message_return_type": "unseen",
                                       "direction": $0.flatMap { _ in "older" },
                                       "cursor": $0,
                                       "limit": "20"])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Conversation.Unit.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }

    /// Delete the current conversation.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func delete() -> Endpoint.Single<Status, Error> {
        edit("hide/", body: ["use_unified_inbox": "true"])
    }

    /// Invite users based on their identifier.
    ///
    /// - parameter userIdentifiers: A collection of `String`s.
    /// - returns: A valid `Endpoint.Single`.
    func invite<C: Collection>(_ userIdentifiers: C) -> Endpoint.Single<Status, Error> where C.Element == String {
        edit("add_user/", body: ["user_ids": "["+userIdentifiers.joined(separator: ",")+"]"])
    }

    /// Invite a user based on their identifier.
    ///
    /// - parameter userIdentifier: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func invite(_ userIdentifier: String) -> Endpoint.Single<Status, Error> {
        invite([userIdentifier])
    }

    /// Leave the current conversation.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func leave() -> Endpoint.Single<Status, Error> {
        edit("leave/")
    }

    /// Mute the current conversation.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func mute() -> Endpoint.Single<Status, Error> {
        edit("mute/")
    }

    /// Send a message in the current conversation.
    ///
    /// - parameter text: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func send(_ text: String) -> Endpoint.Single<Wrapper, Error> {
        .init { secret, session in
            do {
                // Prepare the body.
                var method = "text"
                var body: [String: String] = ["thread_ids": "["+self.identifier+"]"]
                // Prepare the detector.
                let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: text, options: [], range: .init(location: 0, length: text.utf16.count))
                    .compactMap { Range($0.range, in: text).flatMap { "\""+text[$0]+"\"" }}
                if !matches.isEmpty {
                    method = "link"
                    body["link_text"] = text
                    body["link_urls"] = "["+matches.joined(separator: ",")+"]"
                } else {
                    body["text"] = text
                }
                // Prepare the request.
                return Swiftagram.Request.directThreads
                    .broadcast.path(appending: method)
                    .path(appending: "/")
                    .header(appending: secret.header)
                    .body(appending: body)
                    .body(appending: ["_csrftoken": secret["csrftoken"]!,
                                      "_uuid": secret.client.device.identifier.uuidString,
                                      "device_id": secret.client.device.instagramIdentifier,
                                      "client_context": UUID().uuidString,
                                      "action": "send_item"])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .eraseToAnyPublisher()
            } catch {
                return Deferred { Fail(error: error) }.eraseToAnyPublisher()
            }
        }
    }

    /// Update the title for the current conversation.
    ///
    /// - parameter title: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func title(_ title: String) -> Endpoint.Single<Status, Error> {
        edit("update_title/", body: ["title": title])
    }

    /// Unmute the current conversation.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unmute() -> Endpoint.Single<Status, Error> {
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
    func edit(_ endpoint: String, body: [String: String] = [:]) -> Endpoint.Single<Status, Error> {
        .init { secret, session in
            Deferred {
                Swiftagram.Request.directThread(self)
                    .path(appending: endpoint)
                    .header(appending: secret.header)
                    .body(appending: ["_csrftoken": secret["csrftoken"]!,
                                      "_uuid": secret.client.device.identifier.uuidString])
                    .body(appending: body)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Status.init)
            }
            .replaceFailingWithError()
        }
    }
}
