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

    /// Perform a test on `Endpoint` returning a `Disposable` `Wrappable`.
    @discardableResult
    func performTest<W: Wrappable, E: Error>(on endpoint: Endpoint.Disposable<W, E>,
                                             _ identifier: String,
                                             logging level: Logger.Level? = nil,
                                             line: Int = #line) -> Wrapper? {
        // Perform the actual test.
        let completion = XCTestExpectation()
        let reference = ReferenceType<Wrapper>()
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
                    reference.value = wrapper
                }
            )
            .store(in: &bin)
        wait(for: [completion], timeout: timeout)
        return reference.value
    }

    /// Perform a test on `Endpoint` returning an `Equatable`.
    @discardableResult
    func performTest<T: Equatable, E: Error>(on endpoint: Endpoint.UnlockedDisposable<T, E>,
                                             comparison: T,
                                             _ identifier: String,
                                             logging level: Logger.Level? = nil,
                                             line: Int = #line) -> T? {
        // Perform the actual test.
        let completion = XCTestExpectation()
        let reference = ReferenceType<T>()
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
                                                logging level: Logger.Level? = nil,
                                                line: Int = #line) -> Wrapper?
    where P: Ranked, P.Offset: ComposableOptionalType, P.Rank: ComposableOptionalType {
        // Perform the actual test.
        let completion = XCTestExpectation()
        let reference = ReferenceType<Wrapper>()
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
                    reference.value = wrapper
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
                                                logging level: Logger.Level? = nil,
                                                line: Int = #line) -> Wrapper?
    where P: ComposableOptionalType {
        // Perform the actual test.
        let completion = XCTestExpectation()
        let reference = ReferenceType<Wrapper>()
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
                    reference.value = wrapper
                }
            )
            .store(in: &bin)
        wait(for: [completion], timeout: timeout)
        return reference.value
    }

    // MARK: Endpoints

    /// Test `Endpoint.Direct`.
    func testEndpointDirect() {
        performTest(on: Endpoint.Direct.inbox, "Endpoint.Direct.Inbox")
        performTest(on: Endpoint.Direct.pendingInbox, "Endpoint.Direct.pendingInbox")
        performTest(on: Endpoint.Direct.presence, "Endpoint.Direct.presence")
        performTest(on: Endpoint.Direct.recipients(), "Endpoint.Direct.recipients()")
        performTest(on: Endpoint.Direct.conversation(matching: "340282366841710300949128174006150953754"),
                    "Endpoint.Direct.conversation")
    }

    /// Test `Endpoint.Discover`.
    func testEndpointDiscover() {
        performTest(on: Endpoint.Discover.users(like: "25025320"),
                    "Endpoint.Discover.usersLike")  // Instagram pk.
        performTest(on: Endpoint.Discover.explore, "Endpoint.Discover.explore")
        performTest(on: Endpoint.Discover.topics, "Endpoint.Discover.topics")
    }

    /// Test `Endpoint.Friendship`.
    func testEndpointFriendship() {
        performTest(on: Endpoint.Friendship.followed(by: "25025320"),
                    "Endpoint.Friendship.followedBy")
        performTest(on: Endpoint.Friendship.following("25025320"),
                    "Endpoint.Friendship.following")
        performTest(on: Endpoint.Friendship.followed(by: "25025320", matching: "a"),
                    "Endpoint.Friendship.followedByMatching")
        performTest(on: Endpoint.Friendship.following("25025320", matching: "a"),
                    "Endpoint.Friendship.followingMatching")
        performTest(on: Endpoint.Friendship.summary(for: "25025320"),
                    "Endpoint.Friendship.summary")
        performTest(on: Endpoint.Friendship.summary(for: ["25025320"]),
                    "Endpoint.Friendship.summaryMultiple")
        performTest(on: Endpoint.Friendship.pendingRequests,
                    "Endpoint.Friendship.pendingRequests")
        performTest(on: Endpoint.Friendship.follow("25025320"),
                    "Endpoint.Friendship.follow")
        performTest(on: Endpoint.Friendship.unfollow("25025320"),
                    "Endpoint.Friendship.unfollow")
    }

    /// Test `Endpoint.Media`.
    func testEndpointMedia() {
        performTest(on: Endpoint.Media.summary(for: "2345240077849019656"),
                    "Endpoint.Media.summary")
        performTest(on: Endpoint.Media.permalink(for: "2345240077849019656"),
                    "Endpoint.Media.permalink")
    }

    /// Test `Endpoint.Media.Posts`.
    func testEndpointPosts() {
        performTest(on: Endpoint.Media.Posts.identifier(for: URL(string: "https://www.instagram.com/p/CK_odwyBEcL/")!),
                    comparison: "2503897884945303307",
                    "Endpoint.Media.Posts.identifier")
        performTest(on: Endpoint.Media.Posts.timeline, "Endpoint.Media.Posts.timeline")
        performTest(on: Endpoint.Media.Posts.liked, "Endpoint.Media.Posts.liked")
        performTest(on: Endpoint.Media.Posts.saved, "Endpoint.Media.Posts.saved")
        performTest(on: Endpoint.Media.Posts.owned(by: "25025320"), "Endpoint.Media.Posts.owned")
        performTest(on: Endpoint.Media.Posts.including("25025320"), "Endpoint.Media.Posts.including")
        performTest(on: Endpoint.Media.Posts.tagged(with: "instagram"), "Endpoint.Media.Posts.tagged")
        performTest(on: Endpoint.Media.Posts.like("2503897884945303307"), "Endpoint.Media.Posts.like")
        performTest(on: Endpoint.Media.Posts.likers(for: "2503897884945303307"), "Endpoint.Media.Posts.likers")
        performTest(on: Endpoint.Media.Posts.unlike("2503897884945303307"), "Endpoint.Media.Posts.unlike")
        performTest(on: Endpoint.Media.Posts.comments(for: "2503897884945303307"), "Endpoint.Media.Posts.comments")
        performTest(on: Endpoint.Media.Posts.archive("2503897884945303307"), "Endpoint.Media.Posts.archive")
        performTest(on: Endpoint.Media.Posts.unarchive("2503897884945303307"), "Endpoint.Media.Posts.unarchive")
        performTest(on: Endpoint.Media.Posts.save("2503897884945303307"), "Endpoint.Media.Posts.save")
        performTest(on: Endpoint.Media.Posts.unsave("2503897884945303307"), "Endpoint.Media.Posts.unsave")
        performTest(on: Endpoint.Media.Posts.like(comment: "18159034204108974"), "Endpoint.Media.Posts.likeComment")
        performTest(on: Endpoint.Media.Posts.unlike(comment: "18159034204108974"), "Endpoint.Media.Posts.unlikeComment")
        if let wrapper = performTest(on: Endpoint.Media.Posts.upload(image: Color.red.image(sized: .init(width: 640, height: 640)),
                                                                     captioned: nil,
                                                                     tagging: [/*.init(x: 0.5, y: 0.5, identifier: "25025320")*/]),
                                     "Endpoint.Media.Posts.uploadImage"),
           let identifier = wrapper.media.id.string() {
            performTest(on: Endpoint.Media.delete(identifier), "Endpoint.Media.Posts.deleteImage")
        }
        if let wrapper = performTest(on: Endpoint.Media.Posts.upload(video: URL(string: "https://raw.githubusercontent.com/sbertix/Swiftagram/main/Resources/landscape.mp4")!,
                                                                     preview: Color.blue.image(sized: .init(width: 640, height: 360)),
                                                                     captioned: nil,
                                                                     tagging: [/*.init(x: 0.5, y: 0.5, identifier: "25025320")*/]),
                                     "Endpoint.Media.Posts.uploadVideo"),
           let identifier = wrapper.media.id.string() {
            performTest(on: Endpoint.Media.delete(identifier), "Endpoint.Media.Posts.deleteVideo")
        }
    }

    /// Test `Endpoint.Media.Stories`.
    func testEndpointStories() {
        performTest(on: Endpoint.Media.Stories.followed, "Endpoint.Media.Stories.followed")
        performTest(on: Endpoint.Media.Stories.archived, "Endpoint.Media.Stories.archived")
        performTest(on: Endpoint.Media.Stories.highlights(for: "25025320"), "Endpoint.Media.Stories.highlights")
        performTest(on: Endpoint.Media.Stories.owned(by: "25025320"), "Endpoint.Media.Stories.owned")
        performTest(on: Endpoint.Media.Stories.owned(by: ["25025320"]), "Endpoint.Media.Stories.ownedMultiple")
        if let wrapper = performTest(on: Endpoint.Media.Stories.upload(image: Color.black.image(sized: .init(width: 810, height: 1440)),
                                                                       stickers: [Sticker.mention("25025320")
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
                                     "Endpoint.Media.Stories.uploadImage"),
           let identifier = wrapper.media.id.string() {
            performTest(on: Endpoint.Media.delete(identifier), "Endpoint.Media.Stories.deleteImage")
        }
//        if let wrapper = performTest(on: Endpoint.Media.Stories.upload(video: URL(string: "https://raw.githubusercontent.com/sbertix/Swiftagram/main/Resources/portrait.mp4")!,
//                                                                       stickers: [.mention("25025320")]),
//                                     "Endpoint.Media.Stories.uploadVideo"),
//           let identifier = wrapper.media.id.string() {
//            performTest(on: Endpoint.Media.delete(identifier), "Endpoint.Media.Stories.deleteVideo")
//        }
    }

    /// Test `Endpoint.News`.
    func testEndpointNews() {
        performTest(on: Endpoint.News.recent, "Endpoint.News.recent")
    }

    /// Test `Endpoint.User`.
    func testEndpointUser() {
        performTest(on: Endpoint.User.blocked, "Endpoint.User.blocked")
        performTest(on: Endpoint.User.summary(for: "25025320"), "Endpoint.User.summary")
        performTest(on: Endpoint.User.all(matching: "instagram"), "Endpoint.User.all")
    }

    /// Test location endpoints.
    func testEndpointLocation() {
        performTest(on: Endpoint.Location.around(coordinates: .init(latitude: 45.434272, longitude: 12.338509)),
                    "Endpoint.Location.around")
        performTest(on: Endpoint.Location.summary(for: "189075947904164"), "Endpoint.Location.summary")
        performTest(on: Endpoint.Location.stories(at: "189075947904164"), "Endpoint.Location.stories")
    }
}
//swiftlint enable:line_length

#endif
