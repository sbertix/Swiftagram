import ComposableRequest
import Foundation
@testable import Swiftagram
@testable import SwiftagramCrypto
import XCTest

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

/// The default request timeout.
let timeout: TimeInterval = 60

/// A custom reference typed wrapper.
class ReferenceType<T> {
    var value: T?
}

final class SwiftagramEndpointTests: XCTestCase {
    /// A temp `Secret`
    lazy var secret: Secret! = {
        Secret(cookies: [
            HTTPCookie(name: "ds_user_id", value: ProcessInfo.processInfo.environment["DS_USER_ID"]!),
            HTTPCookie(name: "sessionid", value: ProcessInfo.processInfo.environment["SESSIONID"]!),
            HTTPCookie(name: "csrftoken", value: ProcessInfo.processInfo.environment["CSRFTOKEN"]!),
            HTTPCookie(name: "rur", value: ProcessInfo.processInfo.environment["RUR"]!)
        ])
    }()

    // MARK: Lifecycle
    /// Set up.
    override func setUp() {
        // Create a custom configuration.
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpMaximumConnectionsPerHost = 1
        // Update requester.
        Requester.default = .init(configuration: .init(sessionConfiguration: sessionConfiguration,
                                                       dispatcher: .init(),
                                                       waiting: 2...3))
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
        endpoint.unlocking(with: secret).task {
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
        endpoint.unlocking(with: secret).task {
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
        endpoint.unlocking(with: secret).task {
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

    /// Test `Endpoint.Highlights`.
    func testEndpointHighlights() {
        performTest(on: Endpoint.Highlights.tray(for: secret.id))
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
        performTest(on: Endpoint.Media.Posts.by(secret.id))
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
            performTest(on: Endpoint.Media.Posts.delete(matching: identifier))
        }
    }

    /// Test `Endpoint.Media.Stories`.
    func testEndpointStories() {
        performTest(on: Endpoint.Media.Stories.followed)
        performTest(on: Endpoint.Media.Stories.archived())
        performTest(on: Endpoint.Media.Stories.by("25025320"))
        if let wrapper = performTest(on: Endpoint.Media.Stories.upload(image: Color.black.image(sized: .init(width: 810, height: 1440)))),
           let identifier = wrapper.media.id.string() {
            performTest(on: Endpoint.Media.delete(matching: identifier))
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

    static var allTests = [
        ("Endpoint.Direct", testEndpointDirect),
        ("Endpoint.Discover", testEndpointDiscover),
        ("Endpoint.Friendship", testEndpointFriendship),
        ("Endpoint.Highlights", testEndpointHighlights),
        ("Endpoint.Media", testEndpointMedia),
        ("Endpoint.Media.Posts", testEndpointPosts),
        ("Endpoint.Media.Stories", testEndpointStories),
        ("Endpoint.News", testEndpointNews),
        ("Endpoint.User", testEndpointUser),
        ("Endpoint.Location", testEndpointLocation)
    ]
}
