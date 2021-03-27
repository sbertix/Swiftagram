//
//  Direct+Conversation.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 25/03/21.
//

import Foundation

public extension Endpoint.Direct {
    /// A `struct` defining a wrapper for a specific conversation.
    struct Conversation: Parent {
        /// The identifier.
        public let identifier: String
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
    /// - returns: A valid `Endpoint.Disposable`.
    func conversation(_ identifier: String) -> Endpoint.Disposable<Swiftagram.Conversation.Unit, Error> {
        conversation(identifier).summary
    }
}

extension Request {
    /// A specific thread bease request.
    ///
    /// - parameter conversation: A valid `Conversation`.
    static func directThread(_ conversation: Endpoint.Direct.Conversation) -> Request {
        Request.directThreads.path(appending: conversation.identifier)
    }
}

public extension Endpoint.Direct.Conversation {
    /// A summary for the current conversation.
    ///
    /// - note: Use `Endpoint.Direct.conversation(_:)` instead.
    internal var summary: Endpoint.Disposable<Conversation.Unit, Error> {
        .init { secret, session in self.messages.unlock(with: secret).session(session).pages(1) }
    }

    /// Paginate all messages in the conversation.
    var messages: Endpoint.Paginated<Conversation.Unit, String?, Error> {
        paginated(at: .directThread(self)) {
            $3.query(appending: ["visual_message_return_type": "unseen",
                                 "direction": $2.flatMap { _ in "older" },
                                 "cursor": $2,
                                 "limit": "20"])
        }
    }

    /// Approve the current conversation request.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func approve() -> Endpoint.Disposable<Status, Error> {
        disposable(at: Request.directThread(self).path(appending: "approve/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString])
        }
    }

    /// Decline the current conversation request.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func decline() -> Endpoint.Disposable<Status, Error> {
        disposable(at: Request.directThread(self).path(appending: "reject/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString])
        }
    }

    /// Delete the current conversation.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func delete() -> Endpoint.Disposable<Status, Error> {
        disposable(at: Request.directThread(self).path(appending: "hide/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString,
                                "use_unified_inbox": "true"])
        }
    }

    /// Invite users based on their identifier.
    ///
    /// - parameter userIdentifiers: A collection of `String`s.
    /// - returns: A valid `Endpoint.Disposable`.
    func invite<C: Collection>(_ userIdentifiers: C) -> Endpoint.Disposable<Status, Error> where C.Element == String {
        disposable(at: Request.directThread(self).path(appending: "add_user/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString,
                                "user_ids": "["+userIdentifiers.joined(separator: ",")+"]"])
        }
    }

    /// Invite a user based on their identifier.
    ///
    /// - parameter userIdentifier: A valid `String`.
    /// - returns: A valid `Endpoint.Disposable`.
    func invite(_ userIdentifier: String) -> Endpoint.Disposable<Status, Error> {
        invite([userIdentifier])
    }

    /// Leave the current conversation.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func leave() -> Endpoint.Disposable<Status, Error> {
        disposable(at: Request.directThread(self).path(appending: "leave/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString])
        }
    }

    /// Mute the current conversation.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    func mute() -> Endpoint.Disposable<Status, Error> {
        disposable(at: Request.directThread(self).path(appending: "mute/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString])
        }
    }

    /// Send a message in the current conversation.
    ///
    /// - parameter text: A valid `String`.
    /// - returns: A valid `Endpoint.Disposable`.
    func send(_ text: String) -> Endpoint.Disposable<Wrapper, Error> {
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
                return self.disposable(at: Request.directThreads.broadcast.path(appending: method).path(appending: "/")) {
                    $2.body(appending: body)
                        .body(appending: ["_csrftoken": $0["csrftoken"]!,
                                          "_uuid": $0.client.device.identifier.uuidString,
                                          "device_id": $0.client.device.instagramIdentifier,
                                          "client_context": UUID().uuidString,
                                          "action": "send_item"])
                }.unlock(with: secret).session(session).eraseToAnyPublisher()
            } catch {
                return Deferred { Fail(error: error) }.eraseToAnyPublisher()
            }
        }
    }

    /// Update the title for the current conversation.
    ///
    /// - parameter title: A valid `String`.
    /// - returns: A valid `Endpoint.Disposable`.
    func title(_ title: String) -> Endpoint.Disposable<Status, Error> {
        disposable(at: Request.directThread(self).path(appending: "update_title/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString,
                                "title": title])
        }
    }

    /// Unmute the current conversation.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    func unmute() -> Endpoint.Disposable<Status, Error> {
        disposable(at: Request.directThread(self).path(appending: "unmute/")) {
            $2.body(appending: ["_csrftoken": $0["csrftoken"]!,
                                "_uuid": $0.client.device.identifier.uuidString])
        }
    }
}
