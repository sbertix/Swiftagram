//
//  ModelTests.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 17/08/2020.
//

#if !os(watchOS) && canImport(XCTest)

import Foundation
import XCTest

import ComposableRequest
@testable import Swiftagram

final class ModelTests: XCTestCase {
    // MARK: Testers
    /// Assess equality.
    /// 
    /// - parameters:
    ///     - dictionary: A valid dictionary of `Wrapper`s.
    ///     - type: A `ReflectedType` concrete implementation.
    ///     - mapper: An association between the original dictionary `key` and the `ReflectedType` `properties`'. Defaults to empty.
    ///     - forcingWrapper: Whether you should bypass mapping or not. Defaults to `false`.
    ///     - wrapper: A custom fallback implementation for non 1-to-1 `mapper` keys, starting from the unmapped key.
    func performTest<T: ReflectedType>(on dictionary: [String: Wrapper],
                                       to type: T.Type,
                                       mapper: [String: String] = [:],
                                       forcingWrapper: Bool = false,
                                       wrapper: (T, String) -> Wrapper = { _, _ in .empty }) {
        let response = T(wrapper: dictionary.wrapped)
        let name = String(describing: type)
        dictionary.forEach { key, value in
            let responseKey = mapper[key] ?? key
            if !forcingWrapper, let responseKeyPath = T.properties[responseKey] {
                // Check for value.
                switch response[keyPath: responseKeyPath] {
                case let wrapper as Wrapper:
                    XCTAssert(value == wrapper, "\"\(key)\" value did not match \"\(responseKey)\" in \(name).")
                case let wrappable as Wrappable:
                    XCTAssert(value == wrappable.wrapped, "\"\(key)\" value did not match \"\(responseKey)\" in \(name).")
                case let wrapped as Wrapped:
                    XCTAssert(value == wrapped.wrapper(), "\"\(key)\" value did not match \"\(responseKey)\" in \(name).")
                case let wrapped as [Wrapped]:
                    XCTAssert(value == wrapped.map { $0.wrapper() }.wrapped, "\"\(key)\" value did not match \"\(responseKey)\" in \(name).")
                case let wrapped as [String: Wrapped]:
                    XCTAssert(value == wrapped.mapValues { $0.wrapper() }.wrapped, "\"\(key)\" value did not match \"\(responseKey)\" in \(name).")
                case let date as Date:
                    XCTAssert(value == date.timeIntervalSince1970.wrapped, "\"\(key)\" value did not match \"\(responseKey)\" in \(name).")
                default:
                    print("\"\(key)\" value in \(name) is neither `Wrapped` nor `Wrappable`: skipped.")
                }
            } else {
                // Check for value.
                XCTAssert(value == wrapper(response, key), "\"\(key)\" value did not match the fallback value for \(name).")
            }
        }
    }

    /// Test `Comment`.
    func testComment() {
        let dictionary: [String: Wrapper] = ["text": "text",
                                             "commentLikeCount": 1,
                                             "user": ["pk": 232]]
        performTest(on: dictionary, to: Comment.self, mapper: ["commentLikeCount": "likes"])
        performTest(on: ["previewComments": [dictionary.wrapped].wrapped],
                    to: Comment.Collection.self,
                    mapper: ["previewComments": "comments"])
    }

    /// Test `Friendship`.
    func testFriendship() {
        let dictionary: [String: Wrapper] = ["following": 1,
                                             "followedBy": 1,
                                             "blocking": 1,
                                             "isBestie": 0,
                                             "incomingRequest": 0,
                                             "outgoingRequest": 0,
                                             "isMutingReel": 1,
                                             "muting": 0]
        performTest(on: dictionary,
                    to: Friendship.self,
                    mapper: ["following": "isFollowedByYou",
                             "followedBy": "isFollowingYou",
                             "blocking": "isBlockedByYou",
                             "isBestie": "isCloseFriend",
                             "incomingRequest": "didRequestToFollowYou",
                             "outgoingRequest": "didRequestToFollow",
                             "isMutingReel": "isMutingStories",
                             "muting": "isMutingPosts"])
        performTest(on: ["friendshipStatuses": ["1": dictionary.wrapped].wrapped],
                    to: Friendship.Dictionary.self,
                    mapper: ["friendshipStatuses": "friendships"])
    }

    /// Test `Location`.
    func testLocation() {
        let dictionary: [String: Wrapper] = ["lat": 1,
                                             "lng": 1,
                                             "name": "A Location",
                                             "shortName": "Location",
                                             "address": "Address",
                                             "city": "City",
                                             "externalIdSource": "id",
                                             "externalId": 123]
        performTest(on: dictionary,
                    to: Location.self,
                    wrapper: {
                        switch $1 {
                        case "lat": return ($0.coordinates?.latitude).flatMap(Double.init).wrapped
                        case "lng": return ($0.coordinates?.longitude).flatMap(Double.init).wrapped
                        case "externalIdSource": return ($0.identifier?.keys.first).wrapped
                        case "externalId": return ($0.identifier?.values.first).wrapped
                        default: return .empty
                        }
                    })
        performTest(on: ["location": dictionary.wrapped], to: Location.Unit.self)
        performTest(on: ["venues": [dictionary.wrapped].wrapped], to: Location.Collection.self)
    }

    /// Test `Media`.
    func testMedia() {
        let dictionary: [String: Wrapper] = ["id": "123_123",
                                             "pk": 1,
                                             "expiringAt": 0,
                                             "takenAt": 0,
                                             "originalWidth": 1,
                                             "originalHeight": 1,
                                             "caption": ["text": "Text"],
                                             "commentCount": 2,
                                             "likeCount": 3,
                                             "user": ["pk": 123],
                                             "location": ["name": "Location"]]
        performTest(on: dictionary,
                    to: Media.self,
                    mapper: ["id": "identifier",
                             "pk": "primaryKey",
                             "commentCount": "comments",
                             "likeCount": "likes"],
                    wrapper: {
                        switch $1 {
                        case "originalWidth": return Double($0.size?.width ?? 0).wrapped
                        case "originalHeight": return Double($0.size?.height ?? 0).wrapped
                        default: return .empty
                        }
                    })
        performTest(on: ["media": dictionary.wrapped], to: Media.Unit.self)
        //performTest(on: ["media": [dictionary.wrapped].wrapped], to: Media.Collection.self)
    }

    /// Test `Status`.
    func testStatus() {
        performTest(on: ["status": "ok"],
                    to: Status.self,
                    forcingWrapper: true,
                    wrapper: { status, _ in status.error == nil ? "ok".wrapped : .empty })
    }

    /// Test `Conversation`.
    func testThread() {
        let dictionary: [String: Wrapper] = ["threadId": "123_123",
                                             "threadTitle": "Title",
                                             "lastActivityAt": 0,
                                             "lastSeenAt": [:],
                                             "muted": 1,
                                             "vcMuted": 1,
                                             "users": [],
                                             "items": []]
        performTest(on: dictionary,
                    to: Conversation.self,
                    mapper: ["threadId": "identifier",
                             "threadTitle": "title",
                             "lastActivityAt": "updatedAt",
                             "muted": "hasMutedMessages",
                             "vcMuted": "hasMutedVideocalls",
                             "items": "messages"],
                    wrapper: {
                        switch $1 {
                        case "lastSeenAt": return ($0.openedAt?.mapValues { $0.timeIntervalSince1970 }).wrapped
                        default: return .empty
                        }
                    })
        performTest(on: ["thread": dictionary.wrapped], to: Conversation.Unit.self)
        performTest(on: ["inbox": ["threads": [dictionary.wrapped].wrapped]],
                    to: Conversation.Collection.self,
                    wrapper: { response, _ in ["threads": (response.conversations?.map { $0.wrapper() }).wrapped] })
    }

    /// Test `Recipient`.
    func testThreadRecipient() {
        let dictionary: [String: Wrapper] = ["rankedRecipients": [["user": ["pk": 123]],
                                                                  ["thread": ["threadId": "123"]]]]
        performTest(on: dictionary,
                    to: Recipient.Collection.self,
                    wrapper: { response, _ in
                        (response.recipients?.map { recipient -> [String: Wrapper] in
                            switch recipient {
                            case .user(let user): return ["user": user.wrapper()]
                            case .thread(let conversation): return ["thread": conversation.wrapper()]
                            default: return ["error": .empty]
                            }
                        }).wrapped
                    })
    }

    /// Test `TrayItem`.
    func testTrayItem() {
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
        performTest(on: dictionary,
                    to: TrayItem.self,
                    mapper: ["id": "identifier",
                             "rankedPosition": "position",
                             "seenRankedPosition": "seenPosition",
                             "mediaCount": "availableCount",
                             "prefetchCount": "fetchedCount",
                             "latestReelMedia": "latestMediaPrimaryKey",
                             "coverMedia": "cover",
                             "seen": "lastSeenOn"])
        performTest(on: ["story": dictionary.wrapped], to: TrayItem.Unit.self, mapper: ["story": "item"])
        performTest(on: ["items": [dictionary.wrapped]], to: TrayItem.Collection.self)
        performTest(on: ["reels": ["123_123": dictionary.wrapped]],
                    to: TrayItem.Dictionary.self,
                    mapper: ["reels": "items"])
    }

    /// Test `User`.
    func testUser() {
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
        performTest(on: dictionary,
                    to: User.self,
                    mapper: ["pk": "identifier",
                             "fullName": "name",
                             "profilePicUrl": "thumbnail"],
                    wrapper: {
                        switch $1 {
                        case "hdProfilePicUrlInfo": return ["url": $0.avatar.flatMap { $0.absoluteString }.wrapped]
                        case "isPrivate": return ($0.access == .private).wrapped
                        case "isVerified": return ($0.access == .verified).wrapped
                        case "mediaCount": return ($0.counter?.posts).wrapped
                        case "followerCount": return ($0.counter?.followers).wrapped
                        case "followingCount": return ($0.counter?.following).wrapped
                        case "usertagsCount": return ($0.counter?.tags).wrapped
                        case "totalClipsCount": return ($0.counter?.clips).wrapped
                        case "totalArEffects": return ($0.counter?.effects).wrapped
                        case "totalIgtvVideos": return ($0.counter?.igtv).wrapped
                        default: return .empty
                        }
                    })
        performTest(on: ["user": dictionary.wrapped], to: User.Unit.self)
        performTest(on: ["users": [dictionary.wrapped]], to: User.Collection.self)
    }

    /// Test `UserTag`.
    func testUserTag() {
        let dictionary: [String: Wrapper] = ["userId": "123",
                                             "position": [0, 0]]
        performTest(on: dictionary,
                    to: UserTag.self,
                    mapper: ["userId": "identifier"],
                    wrapper: { response, _ in [response.x.flatMap(Double.init), response.y.flatMap(Double.init)].wrapped })
    }
}

#endif
