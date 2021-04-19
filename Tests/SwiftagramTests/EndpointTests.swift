//
//  EndpointTests.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 17/08/2020.
//

#if !os(watchOS) && canImport(XCTest)

import CoreGraphics
import Foundation
import XCTest

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

@testable import Swiftagram
@testable import SwiftagramCrypto

import SwCrypt

/// The default request timeout.
let timeout: TimeInterval = 30

//swiftlint:disable line_length
/// A `class` dealing with testing all available `Endpoint`s.
final class EndpointTests: XCTestCase {
    /// The underlying dispose bag.
    private var bin: Set<AnyCancellable> = []

    //swiftlint:disable force_try
    /// Read the `Secret`.
    lazy var secret: Secret = {
        let data = Data(base64Encoded: ProcessInfo.processInfo.environment["SECRET"]!.trimmingCharacters(in: .whitespacesAndNewlines))!
        return try! JSONDecoder().decode(Secret.self, from: data)
    }()
    //swiftlint:enable force_try

    // MARK: Tests

    /// Perform a test on `Endpoint` returning a `Single` `Wrappable`.
    @discardableResult
    func performTest<W: Wrappable, E: Error>(on endpoint: Endpoint.Single<W, E>,
                                             _ identifier: String,
                                             logging level: Logger = .default,
                                             line: Int = #line) -> W? {
        // Perform the actual test.
        let completion = XCTestExpectation()
        let reference = Reference<W?>(nil)
        endpoint.unlock(with: secret)
            .session(.instagram, logging: level)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 { XCTFail(error.localizedDescription+" \(identifier) #\(line)") }
                    completion.fulfill()
                },
                receiveValue: {
                    let wrapper = $0.wrapped
                    XCTAssert(wrapper.status.string() == "ok" || wrapper.response.spam.bool() == true, "\(identifier) #\(line)")
                    reference.value = $0
                }
            )
            .store(in: &bin)
        wait(for: [completion], timeout: timeout)
        return reference.value
    }

    /// Perform a test on `Endpoint` returning an `Equatable`.
    @discardableResult
    func performTest<T: Equatable, E: Error>(on endpoint: AnyPublisher<T, E>,
                                             comparison: T,
                                             _ identifier: String,
                                             logging level: Logger = .default,
                                             line: Int = #line) -> T? {
        // Perform the actual test.
        let completion = XCTestExpectation()
        let reference = Reference<T?>(nil)
        endpoint.sink(
            receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription+" \(identifier) #\(line)") }
                completion.fulfill()
            },
            receiveValue: {
                XCTAssert($0 == comparison, "\(identifier) #\(line)")
                reference.value = $0
            }
        )
        .store(in: &bin)
        wait(for: [completion], timeout: timeout)
        return reference.value
    }

    // Perform test on `Endpoint` returning a `Ranked`-`Paginated` `Wrappable`.
    @discardableResult
    func performTest<W: Wrappable, P, E: Error>(on endpoint: Endpoint.Paginated<W, P, E>,
                                                _ identifier: String,
                                                pages: Int = 1,
                                                logging level: Logger = .default,
                                                line: Int = #line) -> W?
    where P: Ranked, P.Offset: ComposableOptionalType, P.Rank: ComposableOptionalType {
        // Perform the actual test.
        let completion = XCTestExpectation()
        let reference = Reference<W?>(nil)
        endpoint.unlock(with: secret)
            .session(.instagram, logging: level)
            .pages(pages)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 { XCTFail(error.localizedDescription+" \(identifier) #\(line)") }
                    completion.fulfill()
                },
                receiveValue: {
                    let wrapper = $0.wrapped
                    XCTAssert(wrapper.status.string() == "ok" || wrapper.response.spam.bool() == true, "\(identifier) #\(line)")
                    reference.value = $0
                }
            )
            .store(in: &bin)
        wait(for: [completion], timeout: timeout)
        return reference.value
    }

    // Perform test on `Endpoint` returning a `Paginated` `Wrappable`.
    @discardableResult
    func performTest<W: Wrappable, P, E: Error>(on endpoint: Endpoint.Paginated<W, P, E>,
                                                _ identifier: String,
                                                pages: Int = 1,
                                                logging level: Logger = .default,
                                                line: Int = #line) -> W?
    where P: ComposableOptionalType {
        // Perform the actual test.
        let completion = XCTestExpectation()
        let reference = Reference<W?>(nil)
        endpoint.unlock(with: secret)
            .session(.instagram, logging: level)
            .pages(pages)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 { XCTFail(error.localizedDescription+" \(identifier) #\(line)") }
                    completion.fulfill()
                },
                receiveValue: {
                    let wrapper = $0.wrapped
                    XCTAssert(wrapper.status.string() == "ok" || wrapper.response.spam.bool() == true, "\(identifier) #\(line)")
                    reference.value = $0
                }
            )
            .store(in: &bin)
        wait(for: [completion], timeout: timeout)
        return reference.value
    }

    // MARK: Endpoints

    /// Test `Endpoint.archived`.
    func testEndpointArchived() {
        performTest(on: Endpoint.posts
                        .archived,
                    "Endpoint.Archived.posts")
        performTest(on: Endpoint.stories
                        .archived,
                    "Endpoint.Archived.stories")
    }

    /// Test `Endpoint.direct`.
    func testEndpointDirect() {
        performTest(on: Endpoint.direct
                        .conversations,
                    "Endpoint.direct.inbox")
        performTest(on: Endpoint.direct
                        .requests,
                    "Endpoint.direct.pendingInbox")
        performTest(on: Endpoint.direct
                        .activity,
                    "Endpoint.direct.activity")
        performTest(on: Endpoint.direct
                        .recipients,
                    "Endpoint.direct.recipients")
        performTest(on: Endpoint.direct
                        .recipients(matching: "Instagram"),
                    "Endpoint.direct.recipientsQuery")
        performTest(on: Endpoint.direct.conversation("340282366841710300949128174006150953754"),
                    "Endpoint.direct.conversation")
        performTest(on: Endpoint.direct
                        .conversation("340282366841710300949128174006150953754")
                        .mute(),
                    "Endpoint.direct.Conversation.mute")
        performTest(on: Endpoint.direct
                        .conversation("340282366841710300949128174006150953754")
                        .unmute(),
                    "Endpoint.direct.Conversation.unmute")
        performTest(on: Endpoint.direct
                        .conversation("340282366841710300949128174006150953754")
                        .message("29822631279915292661700891829600256")
                        .open(),
                    "Endpoint.direct.Conversation.Message.open")
        performTest(on: Endpoint.direct
                        .conversation("340282366841710300949128131067346707174")
                        .invite("208803632"),
                    "Endpoint.direct.Conversation.invite")
        performTest(on: Endpoint.direct
                        .conversation("340282366841710300949128131067346707174")
                        .title("Tests"),
                    "Endpoint.direct.Conversation.title")
        if let identifier = performTest(on: Endpoint.direct
                                            .conversation("340282366841710300949128131067346707174")
                                            .send("This is an automated message."),
                                        "Endpoint.direct.Conversation.send")?.payload.itemId.string() {
            performTest(on: Endpoint.direct
                            .conversation("340282366841710300949128131067346707174")
                            .message(identifier)
                            .delete(),
                        "Endpoint.direct.Conversation.delete")
        }
        if let identifier = performTest(on: Endpoint.direct
                                            .conversation("340282366841710300949128131067346707174")
                                            .send("This is an automated message with links. https://google.com https://instagram.com"),
                                        "Endpoint.direct.Conversation.sendLinks")?.payload.itemId.string() {
            performTest(on: Endpoint.direct
                            .conversation("340282366841710300949128131067346707174")
                            .message(identifier)
                            .delete(),
                        "Endpoint.direct.Conversation.deleteLinks")
        }
    }

    /// Test `Endpoint.Explore`.
    func testEndpointExplore() {
        performTest(on: Endpoint.explore
                        .posts,
                    "Endpoint.Explore.posts")
        performTest(on: Endpoint.explore
                        .topics,
                    "Endpoint.Explore.topics")
    }

    /// Test location endpoints.
    func testEndpointLocation() {
        performTest(on: Endpoint.locations(around: .init(latitude: 45.434272, longitude: 12.338509)),
                    "Endpoint.locationsAround")
        performTest(on: Endpoint.location("189075947904164"),
                    "Endpoint.Location.summary")
        performTest(on: Endpoint.location("189075947904164")
                        .stories,
                    "Endpoint.Location.stories")
    }

    /// Test `Endpoint.Media`.
    func testEndpointMedia() {
        performTest(on: Endpoint.media("2345240077849019656"),
                    "Endpoint.Media.summary")
        if let wrapper = performTest(on: Endpoint.media("2345240077849019656")
                                        .link,
                                     "Endpoint.Media.link"),
           let url = wrapper.url {
            performTest(on: Endpoint.media(at: url),
                        "Endpoint.Media.urlSummary")
        }
        performTest(on: Endpoint.media("2345240077849019656")
                        .save(),
                    "Endpoint.Media.save")
        performTest(on: Endpoint.media("2345240077849019656")
                        .unsave(),
                    "Endpoint.Media.unsave")
        performTest(on: Endpoint.media("2503897884945303307")
                        .likers,
                    "Endpoint.Media.likers")
        performTest(on: Endpoint.media("2503897884945303307")
                        .comments,
                    "Endpoint.Media.comments")
        performTest(on: Endpoint.media("")
                        .comment("18159034204108974")
                        .like(),
                    "Endpoint.Media.Comment.like")
        performTest(on: Endpoint.media("")
                        .comment("18159034204108974")
                        .unlike(),
                    "Endpoint.Media.Comment.unlike")
        performTest(on: Endpoint.media("2503897884945303307")
                        .like(),
                    "Endpoint.Media.like")
        performTest(on: Endpoint.media("2503897884945303307")
                        .unlike(),
                    "Endpoint.Media.unlike")
        performTest(on: Endpoint.media("2503897884945303307")
                        .archive(),
                    "Endpoint.Media.archive")
        performTest(on: Endpoint.media("2503897884945303307")
                        .unarchive(),
                    "Endpoint.Media.unarchive")
        if let wrapper = performTest(on: Endpoint.media("2503897884945303307")
                                        .comment(with: "Test."),
                                     "Endpoint.Media.postComment"),
           let identifier = wrapper.comment?.identifier {
            performTest(on: Endpoint.media("2503897884945303307")
                            .comment(identifier)
                            .delete(),
                        "Endpoint.Media.Comment.delete")
        }
    }

    /// Test `Endpoint.Media.Posts`.
    func testEndpointPosts() {
        performTest(on: Endpoint.posts
                        .liked,
                    "Endpoint.Posts.liked")
        if let wrapper = performTest(on: Endpoint.posts.upload(image: Color.red.image(sized: .init(width: 640, height: 640)),
                                                               captioned: nil,
                                                               tagging: [/*.init(x: 0.5, y: 0.5, identifier: "25025320")*/]),
                                     "Endpoint.Posts.uploadImage"),
           let identifier = wrapper.media?.identifier {
            performTest(on: Endpoint.media(identifier).delete(), "Endpoint.Posts.deleteImage")
        }
        if let wrapper = performTest(on: Endpoint.posts.upload(video: URL(string: "https://raw.githubusercontent.com/sbertix/Swiftagram/main/Resources/landscape.mp4")!,
                                                               preview: Color.blue.image(sized: .init(width: 640, height: 360)),
                                                               captioned: nil,
                                                               tagging: [/*.init(x: 0.5, y: 0.5, identifier: "25025320")*/]),
                                     "Endpoint.Posts.uploadVideo"),
           let identifier = wrapper.media?.identifier {
            performTest(on: Endpoint.media(identifier).delete(), "Endpoint.Posts.deleteVideo")
        }
    }

    /// Test `Endpoint.Recent`.
    func testEndpointRecent() {
        performTest(on: Endpoint.recent
                        .activity,
                    "Endpoint.Recent.activity")
        performTest(on: Endpoint.recent
                        .posts,
                    "Endpoint.Recent.posts")
        performTest(on: Endpoint.recent
                        .stories,
                    "Endpoint.Recent.stories")
    }

    /// Test `Endpoint.Saved`.
    func testEndpointSaved() {
        performTest(on: Endpoint.posts
                        .saved,
                    "Endpoint.Saved.posts")
        if let collection = performTest(on: Endpoint.saved
                                            .collections,
                                        "Endpoint.Saved.collections")?.collections?.last {
            performTest(on: Endpoint.saved
                            .collection(collection),
                        "Endpoint.Saved.Collection.summary")
            performTest(on: Endpoint.saved
                            .collection(collection.identifier),
                        "Endpoint.Saved.Collection.summary")
            if performTest(on: Endpoint.media("2345240077849019656")
                            .save(in: collection.identifier),
                           "Endpoint.Media.saveIn") != nil {
                performTest(on: Endpoint.media("2345240077849019656")
                                .unsave(),
                            "Endpoint.Media.unsave")
            }
        }
    }

    /// Test `Endpoint.Media.Stories`.
    func testEndpointStories() {
        if let wrapper = performTest(on: Endpoint.stories.upload(image: Color.black.image(sized: .init(width: 810, height: 1440)),
                                                                 stickers: [Sticker.mention("208803632")
                                                                                .position(.init(x: 0.0, y: 0.125)),
                                                                            Sticker.tag("instagram")
                                                                                .position(.init(x: 0.5, y: 0.125)),
                                                                            Sticker.location("189075947904164")
                                                                                .position(.init(x: 1.0, y: 0.125)),
                                                                            Sticker.slider("Test?", emoji: "😀")
                                                                                .position(.init(x: 0.5, y: 0.2)),
                                                                            Sticker.countdown(to: Date().addingTimeInterval(60*60*24),
                                                                                              event: "Event")
                                                                                .position(.init(x: 0.5, y: 0.4)),
                                                                            Sticker.question("Test?")
                                                                                .position(.init(x: 0.5, y: 0.6)),
                                                                            Sticker.poll("Test?", tallies: ["A", "B"])
                                                                                .position(.init(x: 0.5, y: 0.8))],
                                                                 isCloseFriendsOnly: true),
                                     "Endpoint.Stories.uploadImage"),
           let identifier = wrapper.media?.identifier {
            performTest(on: Endpoint.media(identifier).delete(), "Endpoint.Stories.deleteImage")
        }
        //        if let wrapper = performTest(on: Endpoint.Media.Stories.upload(video: URL(string: "https://raw.githubusercontent.com/sbertix/Swiftagram/main/Resources/portrait.mp4")!,
        //                                                                       stickers: [.mention("208803632")]),
        //                                     "Endpoint.Media.Stories.uploadVideo"),
        //           let identifier = wrapper.media.id.string() {
        //            performTest(on: Endpoint.Media.delete(identifier), "Endpoint.Media.Stories.deleteVideo")
        //        }
    }

    /// Test tag endpoints.
    func testEndpointTag() {
        performTest(on: Endpoint.tag("instagram")
                        .posts,
                    "Endpoint.Tag.posts")
    }

    /// Test `Endpoint.User`.
    func testEndpointUser() {
        performTest(on: Endpoint.user("25025320"),
                    "Endpoint.User.summary")
        performTest(on: Endpoint.user("25025320")
                        .followers,
                    "Endpoint.User.followers")
        performTest(on: Endpoint.user("25025320")
                        .followers(matching: "a"),
                    "Endpoint.User.followersQuery")
        performTest(on: Endpoint.user("25025320")
                        .following,
                    "Endpoint.User.following")
        performTest(on: Endpoint.user("25025320")
                        .following(matching: "a"),
                    "Endpoint.User.followingQuery")
        performTest(on: Endpoint.user("25025320")
                        .friendship,
                    "Endpoint.User.friendship")
        performTest(on: Endpoint.user("25025320")
                        .similar,
                    "Endpoint.User.similar")
        performTest(on: Endpoint.user(matching: "instagram"),
                    "Endpoint.userMatching")
        performTest(on: Endpoint.users(matching: "instagram"),
                    "Endpoint.usersMatching")
        performTest(on: Endpoint.users
                        .blocked,
                    "Endpoint.Users.blocked")
        performTest(on: Endpoint.users
                        .requests,
                    "Endpoint.Users.requests")
        performTest(on: Endpoint.users(["25025320"])
                        .friendships,
                    "Endpoint.ManyUsers.friendships")
        performTest(on: Endpoint.users(["25025320"])
                        .stories,
                    "Endpoint.ManyUsers.stories")
        performTest(on: Endpoint.user("25025320")
                        .follow(),
                    "Endpoint.User.follow")
        performTest(on: Endpoint.user("25025320")
                        .unfollow(),
                    "Endpoint.User.unfollow")
        performTest(on: Endpoint.user("25025320")
                        .block(),
                    "Endpoint.User.block")
        performTest(on: Endpoint.user("25025320")
                        .unblock(),
                    "Endpoint.User.unblock")
        performTest(on: Endpoint.user("25025320")
                        .posts,
                    "Endpoint.User.posts")
        performTest(on: Endpoint.user("25025320")
                        .tags,
                    "Endpoint.User.tags")
        performTest(on: Endpoint.user("25025320")
                        .higlights,
                    "Endpoint.User.highlights")
        performTest(on: Endpoint.user("25025320")
                        .stories,
                    "Endpoint.User.stories")
    }
}
//swiftlint enable:line_length

#endif
