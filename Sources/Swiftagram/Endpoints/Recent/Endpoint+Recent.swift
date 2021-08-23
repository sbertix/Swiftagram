//
//  Endpoint+Recent.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining a recent wrapper.
    final class Recent { }
}

public extension Endpoint {
    /// A wrapper for timeline-specific endpoints.
    static let recent: Group.Recent = .init()
}

extension Request {
    /// The `feed` base request.
    static let feed = Request.version1.feed.appendingDefaultHeader()

    /// The timeline request.
    ///
    /// - parameters:
    ///     - secret: A valid `Secret`.
    ///     - offset: An optional `String`.
    ///     - rank: A valid `String`.
    /// - returns: A valid `Request`.
    static func timeline(_ secret: Secret, offset: String?, rank: String) -> Request {
        Request.feed
            .path(appending: "timeline/")
            .header(appending: secret.header)
            .header(appending: rank, forKey: "rank_token")
            .header(appending: [
                "X-Ads-Opt-Out": "0",
                "X-Google-AD-ID": secret.client.device.adIdentifier.uuidString,
                "X-DEVICE-ID": secret.client.device.identifier.uuidString,
                "X-FB": "1"
            ])
            .body(["max_id": offset,
                   "reason": offset == nil ? "cold_start_fetch" : "pagination",
                   "is_pull_to_refresh": offset == nil ? "0" : nil,
                   "is_prefetch": "0",
                   "feed_view_info": "",
                   "seen_posts": "",
                   "phone_id": secret.client.device.phoneIdentifier.uuidString,
                   "battery_level": "72",
                   "timezone_offset": "43200",
                   "_csrftoken": secret["csrftoken"],
                   "client_session_id": secret["sessionid"],
                   "device_id": secret.client.device.identifier.uuidString,
                   "_uuid": secret.client.device.identifier.uuidString,
                   "is_charging": "0",
                   "is_async_ads_in_headload_enabled": "0",
                   "rti_delivery_backend": "0",
                   "is_async_ads_double_request": "0",
                   "will_sound_on": "0",
                   "is_async_ads_rti": "0"].compactMapValues { $0 })
    }
}

public extension Endpoint.Group.Recent {
    /// Recent activity related to the logged in account (e.g. followers/following, likes, etc).
    var activity: Endpoint.Single<Wrapper, Error> {
        .init { secret, session in
            Deferred {
                Request.version1
                    .news
                    .inbox
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
            }
            .eraseToAnyPublisher()
        }
    }

    /// Recent posts for accounts followed by the logged in user.
    var posts: Endpoint.Paginated<Wrapper, RankedOffset<String?, String?>, Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? UUID().uuidString
            // Prepare the actual pager.
            return Pager(pages) {
                Request.timeline(secret, offset: $0, rank: rank)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .iterateFirst(stoppingAt: $0) { output -> Instruction<String> in
                        switch output?.nextMaxId.string(converting: true) {
                        case .none:
                            return .stop
                        case "feed_recs_head_load":
                            return (output?.feedItems
                                        .array()?
                                        .last?
                                        .endOfFeedDemarcator
                                        .groupSet
                                        .groups
                                        .array()?
                                        .first(where: { $0.id.string(converting: true) == "past_posts" })?
                                        .nextMaxId
                                        .string())
                                .flatMap(Instruction.load) ?? .stop
                        case let cursor?:
                            return .load(cursor)
                        }
                    }
            }
            .eraseToAnyPublisher()
        }
    }

    /// Recent stories for users and tags followed by the current user.
    ///
    /// - note:
    ///     Keep in mind actual media might not be populated.
    ///     Please rely on `Endpoint.User(_:).stories` or
    ///     `Endpoint.stories(_:)`, when dealing with more
    ///     than one user at the time, to return the actual content.
    var stories: Endpoint.Single<TrayItem.Collection, Error> {
        .init { secret, session in
            Deferred {
                Request.feed
                    .reels_tray
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(TrayItem.Collection.init)
            }
            .replaceFailingWithError()
        }
    }
}
