//
//  EndpointMedia+Posts.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/02/21.
//

import Foundation

import ComposableRequest

public extension Endpoint.Media {
    /// A module-like `enum` holding reference to `media` `Endpoint`s reguarding posts. Requires authentication.
    enum Posts {
        /// A list of all users liking the media matching `identifier`.
        ///
        /// - parameter identifier: A `String` holding reference to a valid post media identifier.
        public static func likers(for identifier: String) -> Endpoint.Paginated<Swiftagram.User.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    base.path(appending: identifier)
                        .likers
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: next, forKey: "max_id")
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.User.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// A list of all comments the media matching `identifier`.
        ///
        /// - parameter identifier: A `String` holding reference to a valid post media identifier.
        public static func comments(for identifier: String,
                                    startingAt page: String? = nil) -> Endpoint.Paginated<Comment.Collection,
                                                                                          RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    base.path(appending: identifier)
                        .comments
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: next, forKey: "max_id")
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Comment.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// Save the media metching `identifier`.
        ///
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func save(_ identifier: String) -> Endpoint.Disposable<Status> {
            .init { secret, session in
                Deferred {
                    base.path(appending: identifier)
                        .path(appending: "save/")
                        .method(.post)
                        .header(appending: secret.header)
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Status.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// Unsave the media metching `identifier`.
        ///
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func unsave(_ identifier: String) -> Endpoint.Disposable<Status> {
            .init { secret, session in
                Deferred {
                    base.path(appending: identifier)
                        .path(appending: "unsave/")
                        .method(.post)
                        .header(appending: secret.header)
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Status.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// Like the comment matching `identifier`.
        ///
        /// - parameter identifier: A `String` holding reference to a valid comment identfiier.
        public static func like(comment identifier: String) -> Endpoint.Disposable<Status> {
            .init { secret, session in
                Deferred {
                    base.path(appending: identifier)
                        .path(appending: "comment_like/")
                        .method(.post)
                        .header(appending: secret.header)
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Status.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// Unlike the comment matching `identifier`.
        ///
        /// - parameter identifier: A `String` holding reference to a valid comment identfiier.
        public static func unlike(comment identifier: String) -> Endpoint.Disposable<Status> {
            .init { secret, session in
                Deferred {
                    base.path(appending: identifier)
                        .path(appending: "comment_unlike/")
                        .method(.post)
                        .header(appending: secret.header)
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Status.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// Liked media.
        public static var liked: Endpoint.Paginated<Swiftagram.Media.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    Endpoint.version1
                        .feed
                        .liked
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: next, forKey: "max_id")
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.Media.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// All saved media.
        public static var saved: Endpoint.Paginated<Swiftagram.Media.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    Endpoint.version1
                        .feed
                        .saved
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .header(appending: ["rank_token": rank,
                                            "include_igtv_preview": "false"])
                        .query(appending: next, forKey: "max_id")
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.Media.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// All archived media.
        public static var archived: Endpoint.Paginated<Swiftagram.Media.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    Endpoint.version1
                        .feed
                        .path(appending: "only_me_feed/")
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: next, forKey: "max_id")
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.Media.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// All posts for user matching `identifier`.
        ///
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func owned(by identifier: String) -> Endpoint.Paginated<Swiftagram.Media.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    Endpoint.version1
                        .feed
                        .user
                        .path(appending: identifier)
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: next, forKey: "max_id")
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.Media.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// All posts a user matching `identifier` is tagged in.
        ///
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func including(_ identifier: String) -> Endpoint.Paginated<Swiftagram.Media.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    Endpoint.version1
                        .usertags
                        .path(appending: identifier)
                        .feed
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: next, forKey: "max_id")
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.Media.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// All media matching `tag`.
        ///
        /// - parameter tag: A `String` holding reference to a valid _#tag_.
        public static func tagged(with tag: String) -> Endpoint.Paginated<Swiftagram.Media.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    Endpoint.version1
                        .feed
                        .tag
                        .path(appending: tag)
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: next, forKey: "max_id")
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.Media.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// Timeline.
        public static var timeline: Endpoint.Paginated<Page<Wrapper, String?>, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages,
                             transformer: {
                                switch $0.nextMaxId.string() {
                                case .none:
                                    return nil
                                case "feed_recs_head_load":
                                    return $0.feedItems
                                        .array()?
                                        .last?
                                        .endOfFeedDemarcator
                                        .groupSet
                                        .groups
                                        .array()?
                                        .first(where: { $0.id.string() == "past_posts" })?
                                        .nextMaxId
                                        .string()
                                case let cursor?:
                                    return cursor
                                }
                             }) { _, next, _ in
                    Endpoint.version1
                        .feed
                        .path(appending: "timeline/")
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .header(appending: [
                            "X-Ads-Opt-Out": "0",
                            "X-Google-AD-ID": secret.client.device.adIdentifier.uuidString,
                            "X-DEVICE-ID": secret.client.device.identifier.uuidString,
                            "X-FB": "1"
                        ])
                        .body(["max_id": next,
                               "reason": next == nil ? "cold_start_fetch" : "pagination",
                               "is_pull_to_refresh": next == nil ? "0" : nil,
                               "is_prefetch": "0",
                               "feed_view_info": "",
                               "seen_posts": "",
                               "phone_id": secret.client.device.phoneIdentifier.uuidString,
                               "battery_level": "72",
                               "timezone_offset": "43200",
                               "_csrftoken": secret["csrftoken"]!,
                               "client_session_id": secret["sessionid"]!,
                               "device_id": secret.client.device.identifier.uuidString,
                               "_uuid": secret.client.device.identifier.uuidString,
                               "is_charging": "0",
                               "is_async_ads_in_headload_enabled": "0",
                               "rti_delivery_backend": "0",
                               "is_async_ads_double_request": "0",
                               "will_sound_on": "0",
                               "is_async_ads_rti": "0"].compactMapValues { $0 })
                        .session(session)
                        .map(\.data)
                        .wrap()
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }
    }
}
