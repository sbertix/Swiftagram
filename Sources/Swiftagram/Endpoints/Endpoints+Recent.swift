//
//  Endpoints+Recent.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

public extension Endpoints.Recent {
    /// Fetch recent profile activity.
    static var activity: Endpoint.Single<AnyDecodable> {
        .init { secret in
            Single {
                Path("https://i.instagram.com/api/v1/news/inbox")
                Headers() // Default headers.
                Headers(secret.header)
                Response(AnyDecodable.self)
            }.eraseToAnySingleEndpoint()
        }
    }

    /// Fetch recent followed stories.
    static var stories: Endpoint.Single<AnyDecodable> {
        .init { secret in
            Single {
                Path("https://i.instagram.com/api/v1/feed/reels_tray")
                Headers() // Default headers.
                Headers(secret.header)
                Response(AnyDecodable.self) // TrayItem.Collection
            }.eraseToAnySingleEndpoint()
        }
    }

    /// Fetch recent timeline items.
    static var posts: Endpoint.Loop<String?, AnyDecodable> {
        let rank: UUID = .init()
        return .init { secret, offset in
            Loop<String?, Single<AnyDecodable>>(startingAt: offset) {
                Path("https://i.instagram.com/api/v1/feed/timeline/")
                Headers() // Default headers.
                Headers(secret.header)
                Headers(rank.uuidString, forKey: "rank_token")
                Headers([
                    "X-Ads-Opt-Out": "0",
                    "X-Google-AD-ID": secret.client.device.adIdentifier.uuidString,
                    "X-DEVICE-ID": secret.client.device.identifier.uuidString,
                    "X-FB": "1"
                ])
                Body(parameters: [
                    "max_id": $0,
                    "reason": $0 == nil ? "cold_start_fetch" : "pagination",
                    "is_pull_to_refresh": $0 == nil ? "0" : nil,
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
                    "is_async_ads_rti": "0"
                ])
                Response(AnyDecodable.self)
            } next: {
                guard let next = $0.nextMaxId.string else { return nil }
                guard next == "feed_recs_head_load" else { return .advance(to: next) }
                return $0
                    .feedItems
                    .array?
                    .last?
                    .endOfFeedDemarcator
                    .groupSet
                    .groups
                    .array?
                    .first { $0.id.string == "past_posts" }?
                    .nextMaxId
                    .string
                    .flatMap(NextAction.advance)
            }.eraseToAnyLoopEndpoint()
        }
    }
}
