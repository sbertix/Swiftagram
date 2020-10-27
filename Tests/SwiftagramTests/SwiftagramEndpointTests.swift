//
//  SwiftagramEndpointTests.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 17/08/2020.
//

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

import ComposableRequest

/// The default request timeout.
let timeout: TimeInterval = 300

/// A custom reference typed wrapper.
class ReferenceType<T> {
    var value: T?
}

//swiftlint:disable line_length
final class SwiftagramEndpointTests: XCTestCase {
    /// The requester.
    lazy var requester: Requester = {
        // Create a custom configuration.
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpMaximumConnectionsPerHost = 1
        sessionConfiguration.timeoutIntervalForRequest = 300
        sessionConfiguration.timeoutIntervalForResource = 600
        // Update requester.
        return .init(configuration: .init(sessionConfiguration: sessionConfiguration,
                                          dispatcher: .init(),
                                          waiting: 2...3))
    }()

    /// A valid `NSLock`.
    static let lock = NSLock()
    /// A valid `Secret`.
    static var secret: Secret!
    /// A temp `Secret`
    var secret: Secret! { Self.secret }

    // MARK: Lifecycle
    /// Set up each and every test.
    override func setUp() {
        // Check for a valid secret.
        defer { Self.lock.unlock() }
        Self.lock.lock()
        guard secret == nil else { return }
        // Fetch a new one.
        let reference = ReferenceType<Secret>()
        let exp = expectation(description: "secret fetcher")
        BasicAuthenticator(username: ProcessInfo.processInfo.environment["IG_USERNAME"]!,
                           password: ProcessInfo.processInfo.environment["IG_PASSWORD"]!)
            .authenticate {
                switch $0 {
                case .success(let secret): reference.value = secret
                default: break
                }
                exp.fulfill()
            }
        // Wait for expectation.
        waitForExpectations(timeout: timeout, handler: nil)
        // Return secret.
        guard let secret = reference.value else { fatalError("Invalid secret.") }
        Self.secret = secret
    }

    // MARK: Testers
    /// Perform test on `Endpoint` returning a `Disposable` `Wrapper`.
    @discardableResult
    func performTest(on endpoint: Endpoint.Disposable<Wrapper>,
                     logging level: Logger.Level? = nil,
                     line: Int = #line,
                     function: String = #function) -> Wrapper? {
        let completion = XCTestExpectation()
        let reference = ReferenceType<Wrapper>()
        endpoint.unlocking(with: secret).task(requester: requester) {
            // Process.
            switch $0 {
            case .success(let response):
                XCTAssert(response.status.string() == "ok" || response.spam.bool() == true, "\(function) #\(line)")
                reference.value = response
            case .failure(let error): XCTFail(error.localizedDescription+" \(function) #\(line)")
            }
            // Complete.
            completion.fulfill()
        }.logging(level: level).resume()
        wait(for: [completion], timeout: timeout)
        return reference.value
    }

    /// Perform test on `Endpoint` returning a `Disposable` `Wrapped`.
    @discardableResult
    func performTest<T: Wrapped>(on endpoint: Endpoint.Disposable<T>,
                                 logging level: Logger.Level? = nil,
                                 line: Int = #line,
                                 function: String = #function) -> Wrapper? {
        let completion = XCTestExpectation()
        let reference = ReferenceType<Wrapper>()
        endpoint.unlocking(with: secret).task(requester: requester) {
            // Process.
            switch $0 {
            case .success(let response):
                XCTAssert(response["status"].string() == "ok" || response["spam"].bool() == true, "\(function) #\(line)")
                reference.value = response.wrapper()
            case .failure(let error): XCTFail(error.localizedDescription+" \(function) #\(line)")
            }
            // Complete.
            completion.fulfill()
        }.logging(level: level).resume()
        wait(for: [completion], timeout: timeout)
        return reference.value
    }

    /// Perform a test on `Endpoint` returning a `Disposable` `ResponseType`.
    @discardableResult
    func performTest<T: ResponseType>(on endpoint: Endpoint.Disposable<T>,
                                      logging level: Logger.Level? = nil,
                                      line: Int = #line,
                                      function: String = #function) -> Wrapper? {
        let completion = XCTestExpectation()
        let reference = ReferenceType<Wrapper>()
        endpoint.unlocking(with: secret).task(requester: requester) {
            // Process.
            switch $0 {
            case .success(let response):
                XCTAssert(response.error == nil || response["spam"].bool() == true, "\(function) #\(line)")
                reference.value = response.wrapper()
            case .failure(let error): XCTFail(error.localizedDescription+" \(function) #\(line)")
            }
            // Complete.
            completion.fulfill()
        }.logging(level: level).resume()
        wait(for: [completion], timeout: timeout)
        return reference.value
    }

    // Perform test on `Endpoint` returning a `Paginated` `Wrapper`.
    @discardableResult
    func performTest(on endpoint: Endpoint.Paginated<Wrapper>,
                     logging level: Logger.Level? = nil,
                     line: Int = #line,
                     function: String = #function) -> Wrapper? {
        let completion = XCTestExpectation()
        let taskCompletion = XCTestExpectation()
        let reference = ReferenceType<Wrapper>()
        endpoint.unlocking(with: secret)
            .task(maxLength: 1,
                  by: requester,
                  onComplete: { XCTAssert($0 == 1); taskCompletion.fulfill() },
                  onChange: {
                    // Process.
                    switch $0 {
                    case .success(let response):
                        XCTAssert(response.status.string() == "ok" || response.spam.bool() == true, "\(function) #\(line)")
                        reference.value = response
                    case .failure(let error): XCTFail(error.localizedDescription+" \(function) #\(line)")
                    }
                    // Complete.
                    completion.fulfill()
                  })
            .logging(level: level)
            .resume()
        wait(for: [completion, taskCompletion], timeout: timeout)
        return reference.value
    }

    /// Perform test on `Endpoint` returning a `Paginated` `Wrapped`.
    @discardableResult
    func performTest<T: Wrapped>(on endpoint: Endpoint.Paginated<T>,
                                 logging level: Logger.Level? = nil,
                                 line: Int = #line,
                                 function: String = #function) -> Wrapper? {
        let completion = XCTestExpectation()
        let taskCompletion = XCTestExpectation()
        let reference = ReferenceType<Wrapper>()
        endpoint.unlocking(with: secret)
            .task(maxLength: 1,
                  by: requester,
                  onComplete: { XCTAssert($0 == 1); taskCompletion.fulfill() },
                  onChange: {
                    // Process.
                    switch $0 {
                    case .success(let response):
                        XCTAssert(response["status"].string() == "ok" || response["spam"].bool() == true, "\(function) #\(line)")
                        reference.value = response.wrapper()
                    case .failure(let error): XCTFail(error.localizedDescription+" \(function) #\(line)")
                    }
                    // Complete.
                    completion.fulfill()
                  })
            .logging(level: level)
            .resume()
        wait(for: [completion, taskCompletion], timeout: timeout)
        return reference.value
    }

    /// Perform a test on `Endpoint` returning a `Paginated` `ResponseType`.
    @discardableResult
    func performTest<T: ResponseType>(on endpoint: Endpoint.Paginated<T>,
                                      logging level: Logger.Level? = nil,
                                      line: Int = #line,
                                      function: String = #function) -> Wrapper? {
        let completion = XCTestExpectation()
        let taskCompletion = XCTestExpectation()
        let reference = ReferenceType<Wrapper>()
        endpoint.unlocking(with: secret)
            .task(maxLength: 1,
                  by: requester,
                  onComplete: { XCTAssert($0 == 1); taskCompletion.fulfill() },
                  onChange: {
                    // Process.
                    switch $0 {
                    case .success(let response):
                        XCTAssert(response.error == nil || response["spam"].bool() == true, "\(function) #\(line)")
                        reference.value = response.wrapper()
                    case .failure(let error): XCTFail(error.localizedDescription+" \(function) #\(line)")
                    }
                    // Complete.
                    completion.fulfill()
                  })
            .logging(level: level)
            .resume()
        wait(for: [completion, taskCompletion], timeout: timeout)
        return reference.value
    }

    // MARK: Endpoints
    /// Test `Endpoint.Direct`.
    func testEndpointDirect() {
        performTest(on: Endpoint.Direct.threads())
        performTest(on: Endpoint.Direct.pendingThreads())
        performTest(on: Endpoint.Direct.presence)
        performTest(on: Endpoint.Direct.recipients())
        performTest(on: Endpoint.Direct.thread(matching: "340282366841710300949128142255881512905"))
    }

    /// Test `Endpoint.Discover`.
    func testEndpointDiscover() {
        performTest(on: Endpoint.Discover.users(like: "25025320"))
        performTest(on: Endpoint.Discover.explore())
        performTest(on: Endpoint.Discover.topics())
    }

    /// Test `Endpoint.Friendship`.
    func testEndpointFriendship() {
        performTest(on: Endpoint.Friendship.followed(by: secret.id))
        performTest(on: Endpoint.Friendship.following(secret.id))
        performTest(on: Endpoint.Friendship.summary(for: "25025320"))
        performTest(on: Endpoint.Friendship.summary(for: ["25025320"]))
        performTest(on: Endpoint.Friendship.pendingRequests())
        performTest(on: Endpoint.Friendship.follow("25025320"))
        performTest(on: Endpoint.Friendship.unfollow("25025320"))
    }

    /// Test `Endpoint.Media`.
    func testEndpointMedia() {
        performTest(on: Endpoint.Media.summary(for: "2345240077849019656"))
        performTest(on: Endpoint.Media.permalink(for: "2345240077849019656"))
    }

    /// Test `Endpoint.Media.Posts`.
    func testEndpointPosts() {
        performTest(on: Endpoint.Media.Posts.liked())
        performTest(on: Endpoint.Media.Posts.saved())
        performTest(on: Endpoint.Media.Posts.owned(by: secret.id))
        performTest(on: Endpoint.Media.Posts.including("25025320"))
        performTest(on: Endpoint.Media.Posts.tagged(with: "instagram"))
        performTest(on: Endpoint.Media.Posts.likers(for: "2366175454991362926_7271269732"))
        performTest(on: Endpoint.Media.Posts.comments(for: "2366175454991362926_7271269732"))
        performTest(on: Endpoint.Media.Posts.like("2366175454991362926_7271269732"))
        performTest(on: Endpoint.Media.Posts.unlike("2366175454991362926_7271269732"))
        performTest(on: Endpoint.Media.Posts.archive("2366175454991362926_7271269732"))
        performTest(on: Endpoint.Media.Posts.unarchive("2366175454991362926_7271269732"))
        performTest(on: Endpoint.Media.Posts.save("2366175454991362926_7271269732"))
        performTest(on: Endpoint.Media.Posts.unsave("2366175454991362926_7271269732"))
        performTest(on: Endpoint.Media.Posts.like(comment: "17885013160654942"))
        performTest(on: Endpoint.Media.Posts.unlike(comment: "17885013160654942"))
        if let wrapper = performTest(on: Endpoint.Media.Posts.upload(image: Color.red.image(sized: .init(width: 640, height: 640)),
                                                                     captioned: nil,
                                                                     tagging: [.init(x: 0.5, y: 0.5, identifier: "25025320")])),
           let identifier = wrapper.media.id.string() {
            performTest(on: Endpoint.Media.delete(identifier))
        }
        if let wrapper = performTest(on: Endpoint.Media.Posts.upload(video: URL(string: "https://raw.githubusercontent.com/sbertix/Swiftagram/main/Resources/landscape.mp4")!,
                                                                     preview: Color.blue.image(sized: .init(width: 640, height: 360)),
                                                                     captioned: nil,
                                                                     tagging: [.init(x: 0.5, y: 0.5, identifier: "25025320")])),
           let identifier = wrapper.media.id.string() {
            performTest(on: Endpoint.Media.delete(identifier))
        }
    }

    /// Test `Endpoint.Media.Stories`.
    func testEndpointStories() {
        performTest(on: Endpoint.Media.Stories.followed)
        performTest(on: Endpoint.Media.Stories.archived())
        performTest(on: Endpoint.Media.Stories.highlights(for: secret.id))
        performTest(on: Endpoint.Media.Stories.owned(by: "25025320"))
        performTest(on: Endpoint.Media.Stories.owned(by: ["183250726"]))
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
                                                                       isCloseFriendsOnly: true)),
           let identifier = wrapper.media.id.string() {
            performTest(on: Endpoint.Media.delete(identifier))
        }
        if let wrapper = performTest(on: Endpoint.Media.Stories.upload(video: URL(string: "https://raw.githubusercontent.com/sbertix/Swiftagram/main/Resources/portrait.mp4")!,
                                                                       stickers: [.mention("25025320")])),
           let identifier = wrapper.media.id.string() {
            performTest(on: Endpoint.Media.delete(identifier))
        }
    }

    /// Test `Endpoint.News`.
    func testEndpointNews() {
        performTest(on: Endpoint.News.recent)
    }

    /// Test `Endpoint.User`.
    func testEndpointUser() {
        performTest(on: Endpoint.User.blocked)
        performTest(on: Endpoint.User.summary(for: secret.id))
        performTest(on: Endpoint.User.all(matching: "instagram"))
    }

    /// Test location endpoints.
    func testEndpointLocation() {
        performTest(on: Endpoint.Location.around(coordinates: .init(latitude: 45.434272, longitude: 12.338509)))
        performTest(on: Endpoint.Location.summary(for: "189075947904164"))
        performTest(on: Endpoint.Location.stories(at: "189075947904164"))
    }
}
//swiftlint enable:line_length
