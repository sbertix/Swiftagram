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
        private static let base = Endpoint.version1.feed.defaultHeader()

        /// Stories tray.
        public static let followedStories: Disposable = base.reels_tray.prepare().locking(Secret.self)
        /// Liked media.
        public static let likes: Paginated = base.liked.paginating().locking(Secret.self)
        /// Timeline.
        public static let timeline: Paginated = Endpoint.version1
            .feed
            .timeline
            .defaultHeader()
            .append(header: [
                "X-Ads-Opt-Out": "0",
                "X-Google-AD-ID": Device.default.googleAdId.uuidString,
                "X-DEVICE-ID": Device.default.deviceGUID.uuidString,
                "X-FB": "1"
            ])
            .prepare { _, _ in nil
                /*
                 (try? $0.get().nextMaxId.string()).flatMap {
                     ["reason": "pagination", "max_id": $0]
                 }
                 */
            }
            .locking(Secret.self) {
                return $0
                    .append(header: $1.header)
                    .replace(body: [
                        "is_prefetch": "0",
                        "feed_view_info": "",
                        "seen_posts": "",
                        "phone_id": Device.default.phoneGUID.uuidString,
                        "is_pull_to_refresh": "0",
                        "battery_level": "72",
                        "timezone_offset": "43200",
                        "device_id": Device.default.deviceIdentifier,
                        "_uuid": Device.default.deviceGUID.uuidString,
                        "is_charging": "0",
                        "will_sound_on": "1",
                        "is_on_screen": "true",
                        "is_async_ads_in_headload_enabled": "false",
                        "is_async_ads_double_request": "false",
                        "is_async_ads_rti": "false",
                        "latest_story_pk": "",
                        "reason": "cold_start_fresh",
                        "_csrftoken": $1.crossSiteRequestForgery.value,
                        "client_session_id": $1.session.value
                    ])
            }
        
        /// All posts for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(by identifier: String) -> Paginated {
            return base.user.append(path: identifier).paginating().locking(Secret.self)
        }

        /// All available stories for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func stories(by identifier: String) -> Paginated {
            return base.user.append(path: identifier).reel_media.paginating().locking(Secret.self)
        }

        /// All available stories for user matching `identifiers`.
        /// - parameter identifiers: A `Collection` of `String`s holding reference to valud user identifiers.
        public static func stories<C: Collection>(by identifiers: C) -> Disposable where C.Element == String {
            return Endpoint.version1.feed.reels_media
                .defaultHeader()
                .prepare()
                .locking(Secret.self) {
                    $0.append(header: $1.header)
                        .signedBody(["_csrftoken": $1.crossSiteRequestForgery.value,
                                     "user_ids": Array(identifiers),
                                     "_uid": $1.identifier ?? "",
                                     "_uuid": Device.default.deviceGUID.uuidString,
                                     "supported_capabilities_new": SupportedCapabilities.default.map { ["name": $0.key, "value": $0.value] },
                                     "source": "feed_timeline"])
                }
        }

        /// All posts a user matching `identifier` is tagged in.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(including identifier: String) -> Paginated {
            return Endpoint.version1.usertags
                .append(path: identifier)
                .feed
                .defaultHeader()
                .paginating()
                .locking(Secret.self)
        }

        /// All media matching `tag`.
        /// - parameter tag: A `String` holding reference to a valid _#tag_.
        public static func tagged(with tag: String) -> Paginated {
            return base.tag.append(path: tag).paginating().locking(Secret.self)
        }
    }
}
