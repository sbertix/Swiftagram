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
        private static let base = Endpoint.version1.feed.appendingDefaultHeader()

        /// Stories tray.
        public static let followedStories: Disposable<TrayItemCollection> = base
            .reels_tray
            .prepare(process: TrayItemCollection.self)
            .locking(Secret.self)

        /// Liked media.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func liked(startingAt page: String? = nil) -> Paginated<Wrapper> {
            return base.liked.paginating(value: page).locking(Secret.self)
        }

        /// All saved media.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func saved(startingAt page: String? = nil) -> Paginated<Wrapper> {
            return base.saved
                .appending(header: "include_igtv_preview", with: "false")
                .paginating(value: page)
                .locking(Secret.self)
        }

        /// Timeline.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func timeline(startingAt page: String? = nil) -> Paginated<Wrapper> {
            return base.appending(path: "timeline/")
                .prepare { request, response in
                    guard let nextMaxId = try? response?.get().nextMaxId.string() else {
                        return (try? request.appending(body: ["reason": "cold_start_fetch", "is_pull_to_refresh": "0"])) ?? request
                    }
                    return request.appending(query: ["max_id": nextMaxId, "reason": "pagination"])
                }
                .locking(Secret.self) {
                    do {
                        return try $0.appending(header: $1.header)
                        .appending(header: [
                            "X-Ads-Opt-Out": "0",
                            "X-Google-AD-ID": $1.device.googleAdId.uuidString,
                            "X-DEVICE-ID": $1.device.deviceGUID.uuidString,
                            "X-FB": "1"
                        ])
                        .appending(body: [
                            "is_prefetch": "0",
                            "feed_view_info": "",
                            "seen_posts": "",
                            "phone_id": $1.device.phoneGUID.uuidString,
                            "is_pull_to_refresh": "0",
                            "battery_level": "72",
                            "timezone_offset": "43200",
                            "_csrftoken": $1.crossSiteRequestForgery.value,
                            "client_session_id": $1.session.value,
                            "device_id": $1.device.deviceGUID.uuidString,
                            "_uuid": $1.device.deviceGUID.uuidString,
                            "is_charging": "0",
                            "is_async_ads_in_headload_enabled": "0",
                            "rti_delivery_backend": "0",
                            "is_async_ads_double_request": "0",
                            "will_sound_on": "0",
                            "is_async_ads_rti": "0"
                        ])
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
        }

        /// All posts for user matching `identifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid user identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func posts(by identifier: String, startingAt page: String? = nil) -> Paginated<Wrapper> {
            return base.user.appending(path: identifier).paginating(value: page).locking(Secret.self)
        }

        /// All available stories for user matching `identifier`.
        /// - parameters
        ///     - identifier: A `String` holding reference to a valid user identifier.
        public static func stories(by identifier: String) -> Disposable<TrayItemUnit> {
            return base.user.appending(path: identifier)
                .reel_media
                .prepare(process: TrayItemUnit.self)
                .locking(Secret.self)
        }

        /// All posts a user matching `identifier` is tagged in.
        /// - parameters
        ///     - identifier: A `String` holding reference to a valid user identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func posts(including identifier: String, startingAt page: String? = nil) -> Paginated<Wrapper> {
            return Endpoint.version1.usertags
                .appending(path: identifier)
                .feed
                .appendingDefaultHeader()
                .paginating(value: page)
                .locking(Secret.self)
        }

        /// All media matching `tag`.
        /// - parameters:
        ///     - tag: A `String` holding reference to a valid _#tag_.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func tagged(with tag: String, startingAt page: String? = nil) -> Paginated<Wrapper> {
            return base.tag.appending(path: tag).paginating(value: page).locking(Secret.self)
        }
    }
}
