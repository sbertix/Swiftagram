//
//  EndpointMedia+Stories.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/02/21.
//

import Foundation

import ComposableRequest

public extension Endpoint.Media {
    /// A module-like `enum` holding reference to `media` `Endpoint`s reguarding stories. Requires authentication.
    enum Stories {
        /// Stories tray.
        public static var followed: Endpoint.Disposable<TrayItem.Collection> {
            .init { secret, session in
                Projectables.Deferred {
                    Endpoint.version1.feed
                        .reels_tray
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(TrayItem.Collection.init)
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }

        /// Return the highlights tray for a specific user.
        ///
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func highlights(for identifier: String) -> Endpoint.Disposable<TrayItem.Collection> {
            .init { secret, session in
                Projectables.Deferred {
                    Endpoint.version1.highlights
                        .path(appending: identifier)
                        .highlights_tray
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .query(appending: [
                            "supported_capabilities_new": try? SupportedCapabilities
                                .default
                                .map { ["name": $0.key, "value": $0.value] }
                                .wrapped
                                .jsonRepresentation(),
                            "phone_id": secret.client.device.phoneIdentifier.uuidString,
                            "battery_level": "72",
                            "is_charging": "0",
                            "will_sound_on": "0"
                        ])
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(TrayItem.Collection.init)
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }

        /// A list of all viewers for the story matching `identifier`.
        ///
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid post media identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func viewers(for identifier: String) -> Endpoint.Paginated<Swiftagram.User.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Projectables.Pager(pages) { _, next, _ in
                    base.path(appending: identifier)
                        .path(appending: "list_reel_media_viewer")
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: next, forKey: "max_id")
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.User.Collection.init)
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }

        /// Archived stories.
        public static var archived: Endpoint.Paginated<TrayItem.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Projectables.Pager(pages) { _, next, _ in
                    Endpoint.version1
                        .archive
                        .reel
                        .day_shells
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: next, forKey: "max_id")
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(TrayItem.Collection.init)
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }

        /// All available stories for user matching `identifier`.
        ///
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func owned(by identifier: String) -> Endpoint.Disposable<TrayItem.Unit> {
            .init { secret, session in
                Projectables.Deferred {
                    Endpoint.version1
                        .feed
                        .user
                        .path(appending: identifier)
                        .reel_media
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(TrayItem.Unit.init)
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }

        /// All available stories for user matching `identifiers`.
        ///
        /// - parameters identifiers: A `Collection` of `String`s holding reference to valud user identifiers.
        public static func owned<C: Collection>(by identifiers: C) -> Endpoint.Disposable<TrayItem.Dictionary> where C.Element == String {
            .init { secret, session in
                Projectables.Deferred {
                    Endpoint.version1
                        .feed
                        .path(appending: "reels_media/")
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .body(["user_ids": "[\(identifiers.joined(separator: ","))]"])
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(TrayItem.Dictionary.init)
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }
    }
}
