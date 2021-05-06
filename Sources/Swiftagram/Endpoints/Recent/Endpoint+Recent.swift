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
        .init { secret, session, pages -> AnyPublisher<Wrapper, Error> in
            // Persist the rank token.
            let rank = pages.rank ?? String(Int.random(in: 1_000..<10_000))
            // Prepare the actual pager.
            return Pager(pages.count, offset: pages.offset.offset) {
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
                    .body(["max_id": $0,
                           "reason": $0 == nil ? "cold_start_fetch" : "pagination",
                           "is_pull_to_refresh": $0 == nil ? "0" : nil,
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
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .iterateFirst(stoppingAt: $0) {
                        switch $0?.nextMaxId.string() {
                        case .none:
                            return nil
                        case "feed_recs_head_load":
                            return $0?.feedItems
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
