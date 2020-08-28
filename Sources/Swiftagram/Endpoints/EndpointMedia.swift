//
//  EndpointMedia.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `media` `Endpoint`s. Requires authentication.
    struct Media {
        /// The base endpoint.
        private static let base = Endpoint.version1.media.appendingDefaultHeader()

        // MARK: Info
        /// A media matching `identifier`'s info.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func summary(for identifier: String) -> Disposable<Swiftagram.Media.Collection> {
            return base.appending(path: identifier)
                .info
                .prepare(process: Swiftagram.Media.Collection.self)
                .locking(Secret.self)
        }

        /// The permalinkg for the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func permalink(for identifier: String) -> Disposable<Wrapper> {
            return base.appending(path: identifier).permalink.prepare().locking(Secret.self)
        }

        /// A `struct` holding reference to `media` `Endpoint`s reguarding posts. Requires authentication.
        public struct Posts {
            /// A list of all users liking the media matching `identifier`.
            /// - parameters:
            ///     - identifier: A `String` holding reference to a valid post media identifier.
            ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func likers(for identifier: String, startingAt page: String? = nil) -> Paginated<Swiftagram.User.Collection> {
                return base.appending(path: identifier)
                    .likers
                    .paginating(process: Swiftagram.User.Collection.self, value: page)
                    .locking(Secret.self)
            }

            /// A list of all comments the media matching `identifier`.
            /// - parameters:
            ///     - identifier: A `String` holding reference to a valid post media identifier.
            ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func comments(for identifier: String, startingAt page: String? = nil) -> Paginated<Comment.Collection> {
                return base.appending(path: identifier)
                    .comments
                    .paginating(process: Comment.Collection.self, value: page)
                    .locking(Secret.self)
            }

            /// Save the media metching `identifier`.
            /// - parameter identifier: A `String` holding reference to a valid media identifier.
            public static func save(_ identifier: String) -> Disposable<Status> {
                return base
                    .appending(path: identifier)
                    .appending(path: "save/")
                    .replacing(method: .post)
                    .prepare(process: Status.self)
                    .locking(Secret.self)
            }

            /// Unsave the media metching `identifier`.
            /// - parameter identifier: A `String` holding reference to a valid media identifier.
            public static func unsave(_ identifier: String) -> Disposable<Status> {
                return base
                    .appending(path: identifier)
                    .appending(path: "unsave/")
                    .replacing(method: .post)
                    .prepare(process: Status.self)
                    .locking(Secret.self)
            }

            /// Like the comment matching `identifier`.
            /// - parameter identifier: A `String` holding reference to a valid comment identfiier.
            public static func like(comment identifier: String) -> Disposable<Status> {
                return base
                    .appending(path: identifier)
                    .appending(path: "comment_like/")
                    .replacing(method: .post)
                    .prepare(process: Status.self)
                    .locking(Secret.self)
            }

            /// Unlike the comment matching `identifier`.
            /// - parameter identifier: A `String` holding reference to a valid comment identfiier.
            public static func unlike(comment identifier: String) -> Disposable<Status> {
                return base
                    .appending(path: identifier)
                    .appending(path: "comment_unlike/")
                    .replacing(method: .post)
                    .prepare(process: Status.self)
                    .locking(Secret.self)
            }

            /// Liked media.
            /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func liked(startingAt page: String? = nil) -> Paginated<Swiftagram.Media.Collection> {
                return Endpoint.version1.feed.appendingDefaultHeader()
                    .liked
                    .paginating(process: Swiftagram.Media.Collection.self, value: page)
                    .locking(Secret.self)
            }

            /// All saved media.
            /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func saved(startingAt page: String? = nil) -> Paginated<Swiftagram.Media.Collection> {
                return Endpoint.version1.feed.appendingDefaultHeader()
                    .saved
                    .appending(header: "include_igtv_preview", with: "false")
                    .paginating(process: Swiftagram.Media.Collection.self, value: page)
                    .locking(Secret.self)
            }

            /// All posts for user matching `identifier`.
            /// - parameters:
            ///     - identifier: A `String` holding reference to a valid user identifier.
            ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func owned(by identifier: String, startingAt page: String? = nil) -> Paginated<Swiftagram.Media.Collection> {
                return Endpoint.version1.feed.appendingDefaultHeader()
                    .user
                    .appending(path: identifier)
                    .paginating(process: Swiftagram.Media.Collection.self, value: page)
                    .locking(Secret.self)
            }

            /// All posts a user matching `identifier` is tagged in.
            /// - parameters
            ///     - identifier: A `String` holding reference to a valid user identifier.
            ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func including(_ identifier: String, startingAt page: String? = nil) -> Paginated<Swiftagram.Media.Collection> {
                return Endpoint.version1.usertags
                    .appending(path: identifier)
                    .feed
                    .appendingDefaultHeader()
                    .paginating(process: Swiftagram.Media.Collection.self, value: page)
                    .locking(Secret.self)
            }

            /// All media matching `tag`.
            /// - parameters:
            ///     - tag: A `String` holding reference to a valid _#tag_.
            ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func tagged(with tag: String, startingAt page: String? = nil) -> Paginated<Swiftagram.Media.Collection> {
                return Endpoint.version1.feed.appendingDefaultHeader()
                    .tag
                    .appending(path: tag)
                    .paginating(process: Swiftagram.Media.Collection.self, value: page)
                    .locking(Secret.self)
            }

            /// Timeline.
            /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func timeline(startingAt page: String? = nil) -> Paginated<Wrapper> {
                return Endpoint.version1.feed.appendingDefaultHeader()
                    .appending(path: "timeline/")
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
        }

        /// A `struct` holding reference to `media` `Endpoint`s reguarding stories. Requires authentication.
        public struct Stories {
            /// Stories tray.
            public static let followed: Disposable<TrayItem.Collection> = Endpoint.version1.feed
                .reels_tray
                .appendingDefaultHeader()
                .prepare(process: TrayItem.Collection.self)
                .locking(Secret.self)

            /// A list of all viewers for the story matching `identifier`.
            /// - parameters:
            ///     - identifier: A `String` holding reference to a valid post media identifier.
            ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func viewers(for identifier: String, startingAt page: String? = nil) -> Paginated<Swiftagram.User.Collection> {
                return base.appending(path: identifier)
                    .appending(path: "list_reel_media_viewer")
                    .paginating(process: Swiftagram.User.Collection.self, value: page)
                    .locking(Secret.self)
            }

            /// Archived stories.
            /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
            public static func archived(startingAt page: String? = nil) -> Paginated<TrayItem.Collection> {
                return Endpoint.version1
                    .archive
                    .reel
                    .day_shells
                    .appendingDefaultHeader()
                    .paginating(process: TrayItem.Collection.self, value: page)
                    .locking(Secret.self)
            }

            /// All available stories for user matching `identifier`.
            /// - parameter identifier: A `String` holding reference to a valid user identifier.
            public static func owned(by identifier: String) -> Disposable<TrayItem.Unit> {
                Endpoint.version1.feed.appendingDefaultHeader()
                    .user
                    .appending(path: identifier)
                    .reel_media
                    .prepare(process: TrayItem.Unit.self)
                    .locking(Secret.self)
            }

            /// All available stories for user matching `identifiers`.
            /// - parameters identifiers: A `Collection` of `String`s holding reference to valud user identifiers.
            public static func owned<C: Collection>(by identifiers: C) -> Endpoint.Disposable<TrayItem.Dictionary> where C.Element == String {
                return Endpoint.version1.feed.appending(path: "reels_media/")
                    .appendingDefaultHeader()
                    .replacing(body: ["user_ids": try? Array(identifiers).wrapped.jsonRepresentation()])
                    .prepare(process: TrayItem.Dictionary.self)
                    .locking(Secret.self)
            }
        }
    }
}
