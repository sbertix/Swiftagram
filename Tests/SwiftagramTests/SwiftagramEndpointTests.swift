import Foundation
@testable import Swiftagram
import ComposableRequest
import XCTest

extension HTTPCookie {
    /// Test.
    convenience init(text: String) {
        self.init(properties: [.name: text,
                               .value: text,
                               .path: "/",
                               .domain: ""])!
    }
}

final class SwiftagramEndpointTests: XCTestCase {
    /// A temp `Secret`
    let secret = Secret(identifier: HTTPCookie(text: "A"),
                        crossSiteRequestForgery: HTTPCookie(text: "B"),
                        session: HTTPCookie(text: "C"))

    /// Test `Endpoint.Archive`.
    func testEndpointArchive() {
        XCTAssert(Endpoint.Archive
            .stories
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/archive/reel/day_shells/")
    }

    /// Test `Endpoint.Direct`.
    func testEndpointDirect() {
        XCTAssert(Endpoint.Direct
            .threads
            .key("key")
            .initial("value")
            .expecting(String.self) { _ in nil }
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/direct_v2/inbox/")
        XCTAssert(Endpoint.Direct.threads.next(.success(.dictionary(["oldestCursor": .string("next")]))) == "next")
        XCTAssert(Endpoint.Direct
            .thread(matching: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/direct_v2/threads/id/")
        XCTAssert(Endpoint.Direct.thread(matching: "id").next(
            .success(.dictionary(["thread": .dictionary(["oldestCursor": .string("next")])]))
        ) == "next")
        XCTAssert(Endpoint.Direct
            .rankedRecipients
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/direct_v2/ranked_recipients/")
    }

    /// Test `Endpoint.Feed`.
    func testEndpointFeed() {
        XCTAssert(Endpoint.Feed
            .followedStories
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/reels_tray/")
        XCTAssert(Endpoint.Feed
            .likes
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/liked/")
        XCTAssert(Endpoint.Feed
            .timeline
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/timeline/")
        XCTAssert(Endpoint.Feed
            .posts(by: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/user/id/")
        XCTAssert(Endpoint.Feed
            .stories(by: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/user/id/reel_media/")
        XCTAssert(Endpoint.Feed
            .posts(including: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/usertags/id/feed/")
        XCTAssert(Endpoint.Feed
            .tagged(with: "tag")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/tag/tag/")
    }

    /// Test `Endpoint.Friendship`.
    func testEndpointFriendship() {
        XCTAssert(Endpoint.Friendship
            .followed(by: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/id/following/")
        XCTAssert(Endpoint.Friendship
            .following("id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/id/followers/")
        XCTAssert(Endpoint.Friendship
            .friendship(with: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/show/id/")
    }

    /// Test `Endpoint.User`.
    func testEndpointUser() {
        XCTAssert(Endpoint.User
            .summary(for: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/users/id/info/")
        XCTAssert(Endpoint.User
            .blocked
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/users/blocked_list/")
        XCTAssert(Endpoint.User
            .all(matching: "query")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/users/search/?q=query")
    }

    func testEndpointDiscover() {
        XCTAssert(Endpoint.Discover
            .explore
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/discover/explore/")
    }

    func testEndpointMedia() {
        XCTAssert(Endpoint.Media
            .summary(for: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/info/")
        XCTAssert(Endpoint.Media
            .likers(for: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/likers/")
        XCTAssert(Endpoint.Media
            .comments(for: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/comments/")
        XCTAssert(Endpoint.Media
            .permalink(for: "id")
            .authenticating(with: secret)
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/permalink/")
    }

    static var allTests = [
        ("Endpoint.Archive", testEndpointArchive),
        ("Endpoint.Direct", testEndpointDirect),
        ("Endpoint.Discover", testEndpointDiscover),
        ("Endpoint.Feed", testEndpointFeed),
        ("Endpoint.Friendship", testEndpointFriendship),
        ("Endpoint.Media", testEndpointMedia),
        ("Endpoint.User", testEndpointUser),
    ]
}
