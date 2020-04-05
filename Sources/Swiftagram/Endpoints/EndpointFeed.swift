//
//  EndpointFeed.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `feed` and `usertags` `Endpoint`s. Requires authentication.
    struct Feed {
        /// The base endpoint.
        private static let base = Endpoint.version1.feed.defaultHeader().locking(into: Lock.self)

        /// Stories tray.
        public static let followedStories = base.reels_tray
        /// Liked media.
        public static let likes = base.liked.paginating()
        /// Timeline.
        public static let timeline = Endpoint.version1
            .feed
            .timeline
            .defaultHeader()
            .header([
                "X-Ads-Opt-Out": "0",
                "X-Google-AD-ID": Device.default.googleAdId.uuidString,
                "X-DEVICE-ID": Device.default.deviceGUID.uuidString,
                "X-FB": "1"
            ])
            .body([
                "is_prefetch": "0",
                "feed_view_info": "",
                "seen_posts": "",
                "phone_id": Device.default.phoneGUID.uuidString,
                "is_pull_to_refresh": "0",
                "battery_level": "72",
                "timezone_offset": "43200",
                "device_id": Device.default.deviceGUID.uuidString,
                "_uuid": Device.default.deviceGUID.uuidString,
                "is_charging": "0",
                "will_sound_on": "1",
                "is_on_screen": "true",
                "is_async_ads_in_headload_enabled": "false",
                "is_async_ads_double_request": "false",
                "is_async_ads_rti": "false",
                "latest_story_pk": "",
                "reason": "cold_start_fresh"
            ])
            .locking {
                guard let secret = $1 as? Secret else {
                    fatalError("A `Swiftagram.Secret` is required to authenticate `.timeline`.")
                }
                return $0.header(secret.headerFields)
                    .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                    .body("client_session_id", value: secret.session.value)
            }
            .paginating(nextBody: {
                (try? $0.get().nextMaxId.string()).flatMap {
                    ["reason": "pagination", "max_id": $0]
                }
            })

        /// All posts for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(by identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.user.append(identifier).paginating()
        }

        /// All available stories for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func stories(by identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.user.append(identifier).reel_media.paginating()
        }

        /// All posts a user matching `identifier` is tagged in.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(including identifier: String) -> Paginated<Lock<Request>, Response> {
            return Endpoint.version1.usertags
                .append(identifier)
                .feed
                .defaultHeader()
                .locking(into: Lock.self)
                .paginating()
        }

        /// All media matching `tag`.
        /// - parameter tag: A `String` holding reference to a valid _#tag_.
        public static func tagged(with tag: String) -> Paginated<Lock<Request>, Response> {
            return base.tag.append(tag).paginating()
        }
    }
}
