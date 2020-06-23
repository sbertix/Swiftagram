import ComposableRequest
import Foundation
@testable import Swiftagram
import XCTest

extension HTTPCookie {
    /// Test.
    convenience init(text: String) {
        self.init(properties: [.name: text,
                               .value: text,
                               .path: "",
                               .domain: ""])!
    }
}

final class SwiftagramEndpointTests: XCTestCase {
    /// A temp `Secret`
    let secret = Secret(cookies: [HTTPCookie(text: "ds_user_id"),
                                  HTTPCookie(text: "sessionid"),
                                  HTTPCookie(text: "csrftoken")])!
    
    /// Test `Endpoint.Archive`.
    func testEndpointArchive() {
        XCTAssert(Endpoint.Archive
            .stories
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/archive/reel/day_shells")
    }
    
    /// Test `Endpoint.Direct`.
    func testEndpointDirect() {
        XCTAssert(Endpoint.Direct
            .threads
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/direct_v2/inbox")
        XCTAssert(Endpoint.Direct
            .thread(matching: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/direct_v2/threads/id")
        XCTAssert(Endpoint.Direct
            .rankedRecipients
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/direct_v2/ranked_recipients")
    }
    
    /// Test `Endpoint.Feed`.
    func testEndpointFeed() {
        XCTAssert(Endpoint.Feed
            .followedStories
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/reels_tray")
        XCTAssert(Endpoint.Feed
            .liked
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/liked")
        XCTAssert(Endpoint.Feed
            .timeline
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/timeline")
        XCTAssert(Endpoint.Feed
            .posts(by: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/user/id")
        XCTAssert(Endpoint.Feed
            .stories(by: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/user/id/reel_media")
        XCTAssert(Endpoint.Feed
            .stories(by: ["id"])
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/reels_media")
        XCTAssert(Endpoint.Feed
            .posts(including: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/usertags/id/feed")
        XCTAssert(Endpoint.Feed
            .tagged(with: "tag")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/tag/tag")
    }
    
    /// Test `Endpoint.Friendship`.
    func testEndpointFriendship() {
        XCTAssert(Endpoint.Friendship
            .followed(by: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/id/following")
        XCTAssert(Endpoint.Friendship
            .following("id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/id/followers")
        XCTAssert(Endpoint.Friendship
            .friendship(with: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/show/id")
        XCTAssert(Endpoint.Friendship
            .pendingRequests
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/pending")
        XCTAssert(Endpoint.Friendship
            .follow("id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/create/id")
        XCTAssert(Endpoint.Friendship
            .unfollow("id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/destroy/id")
        XCTAssert(Endpoint.Friendship
            .remove(follower: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/remove_follower/id")
        XCTAssert(Endpoint.Friendship
            .acceptRequest(from: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/approve/id")
        XCTAssert(Endpoint.Friendship
            .rejectRequest(from: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/reject/id")
        XCTAssert(Endpoint.Friendship
            .block("id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/block/id")
        XCTAssert(Endpoint.Friendship
            .unblock("id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/unblock/id")
    }
    
    /// Test `Endpoint.User`.
    func testEndpointUser() {
        XCTAssert(Endpoint.User
            .summary(for: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/users/id/info")
        XCTAssert(Endpoint.User
            .blocked
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/users/blocked_list")
        XCTAssert(Endpoint.User
            .all(matching: "query")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/users/search?q=query")
        XCTAssert(Endpoint.User
            .report("id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/users/id/flag_user")
    }
    
    func testEndpointDiscover() {
        XCTAssert(Endpoint.Discover
            .explore
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/discover/explore")
    }
    
    func testEndpointMedia() {
        XCTAssert(Endpoint.Media
            .summary(for: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/info")
        XCTAssert(Endpoint.Media
            .likers(for: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/likers")
        XCTAssert(Endpoint.Media
            .comments(for: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/comments")
        XCTAssert(Endpoint.Media
            .permalink(for: "id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/permalink")
        XCTAssert(Endpoint.Media
            .like("id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/like")
        XCTAssert(Endpoint.Media
            .unlike("id")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/id/unlike")
        XCTAssert(Endpoint.Media
            .reportComment("id", in: "mediaId")
            .unlocking(with: secret)
            .request
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/media/mediaId/comment/id/flag")
    }
    
    static var allTests = [
        ("Endpoint.Archive", testEndpointArchive),
        ("Endpoint.Direct", testEndpointDirect),
        ("Endpoint.Discover", testEndpointDiscover),
        ("Endpoint.Feed", testEndpointFeed),
        ("Endpoint.Friendship", testEndpointFriendship),
        ("Endpoint.Media", testEndpointMedia),
        ("Endpoint.User", testEndpointUser)
    ]
}
