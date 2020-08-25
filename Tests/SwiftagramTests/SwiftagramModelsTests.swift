//
//  SwiftagramModelsTests.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 17/08/2020.
//

import Foundation
import XCTest

import ComposableRequest
@testable import Swiftagram

// swiftlint:disable cyclomatic_complexity
final class SwiftagramModelsTest: XCTestCase {
    /// Asset equality.
    func compare<T: Wrapped>(_ dictionary: [String: Wrapper],
                             to type: T.Type,
                             mapper: (String, T) -> Wrapper) -> Bool {
        let wrapper = T(wrapper: dictionary.wrapped)
        return dictionary.allSatisfy {
            let item = mapper($0, wrapper)
            let current = $1 == item
            if !current {
                print($0+" failed the comparison check.")
                print($1, item)
            }
            return current
        } && String(reflecting: wrapper).starts(with: String(describing: type))
    }

    /// Test `Comment`.
    func testComment() {
        // Component.
        let dictionary: [String: Wrapper] = ["text": "text",
                                             "commentLikeCount": 1,
                                             "user": ["pk": 232]]
        XCTAssert(compare(dictionary, to: Comment.self) {
            switch $0 {
            case "text": return $1.text.wrapped
            case "commentLikeCount": return $1.likes.wrapped
            case "user": return ($1.user?.wrapper()).wrapped
            default: return .empty
            }
        })
        // Collection.
        let collection: [String: Wrapper] = ["previewComments": [dictionary.wrapped].wrapped,
                                             "status": "ok"]
        XCTAssert(compare(collection, to: CommentCollection.self) {
            switch $0 {
            case "previewComments": return ($1.comments?.map { $0.wrapper() }).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
    }

    /// Test `Friendship`.
    func testFriendship() {
        // Component.
        let dictionary: [String: Wrapper] = ["following": 1,
                                             "followedBy": 1,
                                             "blocking": 1,
                                             "isBestie": 0,
                                             "incomingRequest": 0,
                                             "outgoingRequest": 0,
                                             "isMutingReel": 1,
                                             "muting": 0]
        XCTAssert(compare(dictionary, to: Friendship.self) {
            switch $0 {
            case "following": return $1.isFollowedByYou.wrapped
            case "followedBy": return $1.isFollowingYou.wrapped
            case "blocking": return $1.isBlockedByYou.wrapped
            case "isBestie": return $1.isCloseFriend.wrapped
            case "incomingRequest": return $1.didRequestToFollow.wrapped
            case "outgoingRequest": return $1.didRequestToFollowYou.wrapped
            case "isMutingReel": return $1.isMutingStories.wrapped
            case "muting": return $1.isMutingPosts.wrapped
            default: return .empty
            }
        })
        // Collection.
        let collection: [String: Wrapper] = ["friendshipStatuses": ["1": dictionary.wrapped].wrapped,
                                             "status": "ok"]
        XCTAssert(compare(collection, to: FriendshipCollection.self) {
            switch $0 {
            case "friendshipStatuses": return ($1.friendships?.mapValues { $0.wrapper() }).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
    }

    /// Test `Location`.
    func testLocation() {
        // Component.
        let dictionary: [String: Wrapper] = ["lat": 1,
                                             "lng": 1,
                                             "name": "A Location",
                                             "shortName": "Location",
                                             "address": "Address",
                                             "city": "City",
                                             "externalIdSource": "id",
                                             "externalId": 123]
        XCTAssert(compare(dictionary, to: Location.self) {
            switch $0 {
            case "lat": return Double($1.coordinates.latitude).wrapped
            case "lng": return Double($1.coordinates.longitude).wrapped
            case "name": return $1.name.wrapped
            case "shortName": return $1.shortName.wrapped
            case "address": return $1.address.wrapped
            case "city": return $1.city.wrapped
            case "externalIdSource": return ($1.identifier?.keys.first).wrapped
            case "externalId": return ($1.identifier?.values.first).wrapped
            default: return .empty
            }
        })
        // Unit.
        let unit: [String: Wrapper] = ["location": dictionary.wrapped,
                                       "status": "ok"]
        XCTAssert(compare(unit, to: LocationUnit.self) {
            switch $0 {
            case "location": return ($1.location?.wrapper()).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
        // Collection.
        let collection: [String: Wrapper] = ["venues": [dictionary.wrapped].wrapped,
                                             "status": "ok"]
        XCTAssert(compare(collection, to: LocationCollection.self) {
            switch $0 {
            case "venues": return ($1.venues?.map { $0.wrapper() }).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
    }

    /// Test `Media`.
    func testMedia() {
        // Component.
        let dictionary: [String: Wrapper] = ["id": "123_123",
                                             "pk": 1,
                                             "code": "code",
                                             "expiringAt": 0,
                                             "takenAt": 0,
                                             "originalWidth": 1,
                                             "originalHeight": 1,
                                             "caption": ["text": "Text"],
                                             "commentCount": 2,
                                             "likeCount": 3,
                                             "hasLiked": 1,
                                             "user": ["pk": 123],
                                             "location": ["name": "Location"]]
        XCTAssert(compare(dictionary, to: Media.self) {
            switch $0 {
            case "id": return $1.identifier.wrapped
            case "pk": return $1.primaryKey.wrapped
            case "code": return $1.code.wrapped
            case "expiringAt": return ($1.expiringAt?.timeIntervalSince1970).wrapped
            case "takenAt": return ($1.takenAt?.timeIntervalSince1970).wrapped
            case "originalWidth": return Double($1.size?.width ?? 0).wrapped
            case "originalHeight": return Double($1.size?.height ?? 0).wrapped
            case "caption": return ($1.caption?.wrapper()).wrapped
            case "commentCount": return $1.comments.wrapped
            case "likeCount": return $1.likes.wrapped
            case "hasLiked": return $1.wasLikedByYou.wrapped
            case "user": return ($1.user?.wrapper()).wrapped
            case "location": return ($1.location?.wrapper()).wrapped
            default: return .empty
            }
        })
        // Unit.
        let unit: [String: Wrapper] = ["media": dictionary.wrapped,
                                       "status": "ok"]
        XCTAssert(compare(unit, to: MediaUnit.self) {
            switch $0 {
            case "media": return ($1.media?.wrapper()).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
        // Collection.
        let collection: [String: Wrapper] = ["items": [dictionary.wrapped].wrapped,
                                             "status": "ok"]
        XCTAssert(compare(collection, to: MediaCollection.self) {
            switch $0 {
            case "items": return ($1.media?.map { $0.wrapper() }).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
    }

    /// Test `Status`.
    func testStatus() {
        // Component.
        let dictionary: [String: Wrapper] = ["status": "ok"]
        XCTAssert(compare(dictionary, to: Comment.self) {
            switch $0 {
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
    }

    /// Test `Thread`.
    func testThread() {
        // Component.
        let dictionary: [String: Wrapper] = ["threadId": "123_123",
                                             "threadTitle": "Title",
                                             "lastActivityAt": 0,
                                             "lastSeenAt": [:],
                                             "muted": 1,
                                             "vcMuted": 1,
                                             "users": [],
                                             "items": []]
        XCTAssert(compare(dictionary, to: Thread.self) {
            switch $0 {
            case "threadId": return $1.identifier.wrapped
            case "threadTitle": return $1.title.wrapped
            case "lastActivityAt": return ($1.updatedAt?.timeIntervalSince1970).wrapped
            case "lastSeenAt": return ($1.openedAt?.mapValues { $0.timeIntervalSince1970 }).wrapped
            case "muted": return $1.hasMutedMessages.wrapped
            case "vcMuted": return $1.hasMutedVideocalls.wrapped
            case "users": return ($1.users?.map { $0.wrapper() }).wrapped
            case "items": return ($1.messages).wrapped
            default: return .empty
            }
        })
        // Unit.
        let unit: [String: Wrapper] = ["thread": dictionary.wrapped,
                                       "status": "ok"]
        XCTAssert(compare(unit, to: ThreadUnit.self) {
            switch $0 {
            case "thread": return ($1.thread?.wrapper()).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
        // Collection.
        let collection: [String: Wrapper] = ["inbox": ["threads": [dictionary.wrapped].wrapped],
                                             "status": "ok"]
        XCTAssert(compare(collection, to: ThreadCollection.self) {
            switch $0 {
            case "inbox": return ["threads": ($1.threads?.map { $0.wrapper() }).wrapped]
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
    }

    /// Test `ThreadRecipient`.
    func testThreadRecipient() {
        // Collection.
        let collection: [String: Wrapper] = ["rankedRecipients": [["user": ["pk": 123]],
                                                                  ["thread": ["threadId": "123"]]],
                                             "status": "ok"]
        XCTAssert(compare(collection, to: ThreadRecipientCollection.self) {
            switch $0 {
            case "rankedRecipients":
                let recipients = $1.recipients ?? []
                return recipients.map { recipient -> [String: Wrapper] in
                    switch recipient {
                    case .user(let user): return ["user": user.wrapper()]
                    case .thread(let thread): return ["thread": thread.wrapper()]
                    default: return ["error": .empty]
                    }
                }.wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
    }

    /// Test `TrayItem`.
    func testTrayItem() {
        // Component.
        let dictionary: [String: Wrapper] = ["id": "123_123",
                                             "rankedPosition": 0,
                                             "seenRankedPosition": 0,
                                             "mediaCount": 10,
                                             "prefetchCount": 0,
                                             "latestReelMedia": 123,
                                             "coverMedia": ["id": "123"],
                                             "title": "Title",
                                             "items": [],
                                             "expiringAt": 0,
                                             "seen": 0,
                                             "user": ["username": "Test"]]
        XCTAssert(compare(dictionary, to: TrayItem.self) {
            switch $0 {
            case "id": return $1.identifier.wrapped
            case "rankedPosition": return $1.position.wrapped
            case "seenRankedPosition": return $1.seenPosition.wrapped
            case "mediaCount": return $1.availableCount.wrapped
            case "prefetchCount": return $1.fetchedCount.wrapped
            case "latestReelMedia": return $1.latestMediaPrimaryKey.wrapped
            case "coverMedia": return $1.cover.flatMap { $0.wrapper() }.wrapped
            case "title": return $1.title.wrapped
            case "expiringAt": return $1.expiringAt.flatMap { $0.timeIntervalSince1970 }.wrapped
            case "seen": return $1.lastSeenOn.flatMap { $0.timeIntervalSince1970 }.wrapped
            case "user": return $1.user.flatMap { $0.wrapper() }.wrapped
            case "items": return ($1.items?.map { $0.wrapper() }).wrapped
            default: return .empty
            }
        })
        // Unit.
        let unit: [String: Wrapper] = ["story": dictionary.wrapped,
                                       "status": "ok"]
        XCTAssert(compare(unit, to: TrayItemUnit.self) {
            switch $0 {
            case "story": return ($1.item?.wrapper()).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
        // Collection.
        let collection: [String: Wrapper] = ["items": [dictionary.wrapped],
                                             "status": "ok"]
        XCTAssert(compare(collection, to: TrayItemCollection.self) {
            switch $0 {
            case "items": return ($1.items?.map { $0.wrapper() }).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
    }

    /// Test `User`.
    func testUser() {
        // Component.
        let dictionary: [String: Wrapper] = ["pk": "100",
                                             "username": "Username",
                                             "fullName": "Name Surname",
                                             "biography": "Hey",
                                             "profilePicUrl": "https://google.com",
                                             "hdProfilePicUrlInfo": ["url": "https://google.com"],
                                             "isPrivate": 1,
                                             "isVerified": 0,
                                             "mediaCount": 1,
                                             "followerCount": 1,
                                             "followingCount": 1,
                                             "usertagsCount": 0,
                                             "totalClipsCount": 0,
                                             "totalArEffects": 0,
                                             "totalIgtvVideos": 0,
                                             "friendship": ["following": 1]]
        XCTAssert(compare(dictionary, to: User.self) {
            switch $0 {
            case "pk": return $1.identifier.wrapped
            case "username": return $1.username.wrapped
            case "fullName": return $1.name.wrapped
            case "biography": return $1.biography.wrapped
            case "profilePicUrl": return $1.thumbnail.flatMap { $0.absoluteString }.wrapped
            case "hdProfilePicUrlInfo": return ["url": $1.avatar.flatMap { $0.absoluteString }.wrapped]
            case "isPrivate": return ($1.access == .private).wrapped
            case "isVerified": return ($1.access == .verified).wrapped
            case "mediaCount": return ($1.counter?.posts).wrapped
            case "followerCount": return ($1.counter?.followers).wrapped
            case "followingCount": return ($1.counter?.following).wrapped
            case "usertagsCount": return ($1.counter?.tags).wrapped
            case "totalClipsCount": return ($1.counter?.clips).wrapped
            case "totalArEffects": return ($1.counter?.effects).wrapped
            case "totalIgtvVideos": return ($1.counter?.igtv).wrapped
            case "friendship": return $1.friendship.flatMap { $0.wrapper() }.wrapped
            default: return .empty
            }
        })
        // Unit.
        let unit: [String: Wrapper] = ["user": dictionary.wrapped,
                                       "status": "ok"]
        XCTAssert(compare(unit, to: UserUnit.self) {
            switch $0 {
            case "user": return ($1.user?.wrapper()).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
        // Collection.
        let collection: [String: Wrapper] = ["users": [dictionary.wrapped],
                                             "status": "ok"]
        XCTAssert(compare(collection, to: UserCollection.self) {
            switch $0 {
            case "users": return ($1.users?.map { $0.wrapper() }).wrapped
            case "status": return $1.status.wrapped
            default: return .empty
            }
        })
    }

    /// Test `UserTag`.
    func testUserTag() {
        // Component.
        let dictionary: [String: Wrapper] = ["user_id": "123",
                                             "position": [0, 0]]
        XCTAssert(compare(dictionary, to: UserTag.self) {
            switch $0 {
            case "user_id": return $1.identifier.wrapped
            case "position": return [$1.x.flatMap(Double.init), $1.y.flatMap(Double.init)].wrapped
            default: return .empty
            }
        })
    }

    static var allTests = [
        ("Comment", testComment),
        ("Friendship", testFriendship),
        ("Location", testLocation),
        ("Media", testMedia),
        ("Status", testStatus),
        ("Thread", testThread),
        ("ThreadRecipient", testThreadRecipient),
        ("TrayItem", testTrayItem),
        ("User", testUser),
        ("UserTag", testUserTag)
    ]
}
// swiftlint:enable cyclomatic_complexity
