import ComposableRequest
import Foundation
@testable import Swiftagram
@testable import SwiftagramCrypto
import XCTest

extension HTTPCookie {
    /// Test.
    convenience init(name: String, value: String?) {
        self.init(properties: [.name: name,
                               .value: value ?? name,
                               .path: "",
                               .domain: ""])!
    }
}

final class SwiftagramEndpointTests: XCTestCase {
    /// A temp `Secret`
    lazy var secret: Secret! = {
        return Secret(cookies: [
            HTTPCookie(name: "ds_user_id", value: ProcessInfo.processInfo.environment["DS_USER_ID"]!),
            HTTPCookie(name: "sessionid", value: ProcessInfo.processInfo.environment["SESSIONID"]!),
            HTTPCookie(name: "mid", value: ProcessInfo.processInfo.environment["MID"]!),
            HTTPCookie(name: "csrftoken", value: ProcessInfo.processInfo.environment["CSRFTOKEN"]!),
            HTTPCookie(name: "rur", value: ProcessInfo.processInfo.environment["RUR"]!)
        ])
    }()

    /// Test `Endpoint.Archive`.
    func testEndpointArchive() {
        let completion = XCTestExpectation()
        let value = XCTestExpectation()
        // fetch.
        Endpoint.Archive.stories()
            .unlocking(with: secret)
            .task(
                maxLength: 1,
                onComplete: {
                    XCTAssert($0 == 1)
                    completion.fulfill()
                },
                onChange: {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                }
            )
            .resume()
        // wait for expectations.
        wait(for: [completion, value], timeout: 30)
    }

    /// Test `Endpoint.Direct`.
    func testEndpointDirect() {
        // Test threads.
        func testThreads() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Direct.threads()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test ranked recipients.
        func testRankedRecipients() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Direct.rankedRecipients
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test thread.
        func testThread() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Direct.thread(matching: "340282366841710300949128142255881512905")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }

        testThreads()
        testRankedRecipients()
        testThread()
    }

    /// Test `Endpoint.Discover`.
    func testEndpointDiscover() {
        // Test users.
        func testUsers() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Discover.users(like: "25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test explore.
        func testExplore() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Discover.explore()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test thread.
        func testTopics() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Discover.topics()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }

        testUsers()
        testExplore()
        testTopics()
    }

    /// Test `Endpoint.Feed`.
    func testEndpointFeed() {
        // Test followed stories.
        func testFollowedStories() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Feed.followedStories
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test liked.
        func testLiked() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Feed.liked()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test saved.
        func testSaved() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Feed.saved()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test posts.
        func testPosts() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Feed.posts(by: "25025320")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test stories.
        func testStories() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Feed.stories(by: "25025320")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test user tags.
        func testUsertags() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Feed.posts(including: "25025320")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test tag.
        func testTag() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Feed.tagged(with: "instagram")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }

        testFollowedStories()
        testLiked()
        testSaved()
        testPosts()
        testStories()
        testUsertags()
        testTag()
    }

    /// Test `Endpoint.Friendship`.
    func testEndpointFriendship() {
        // Test followed.
        func testFollowed() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.followed(by: secret.identifier)
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test following.
        func testFollowing() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.following(secret.identifier)
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test friendship.
        func testFriendship() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.friendship(with: "25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test pending requests.
        func testPendingRequests() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.pendingRequests()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test follow.
        func testFollow() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.follow("25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test unfollow.
        func testUnfollow() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.unfollow("25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }

        testFollowed()
        testFollowing()
        testFriendship()
        testPendingRequests()
        testFollow()
        testUnfollow()
    }

    /// Test `Endpoint.Highlights`.
    func testEndpointHighlights() {
        // Test highlights.
        func testHighlights() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Highlights.highlights(for: secret.identifier)
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }

        testHighlights()
    }

    /// Test `Endpoint.Media`.
    func testEndpointMedia() {
        // Test summary.
        func testSummary() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.summary(for: "2345240077849019656")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test likers.
        func testLikers() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.likers(for: "2345240077849019656")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test comments.
        func testComments() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.comments(for: "2345240077849019656")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test permalink.
        func testPermalink() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.permalink(for: "2345240077849019656")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test crypto like.
        func testCryptoLike() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.like("2345240077849019656")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test crypto unlike.
        func testCryptoUnlike() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.unlike("2345240077849019656")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }

        testSummary()
        testLikers()
        testComments()
        testPermalink()
        testCryptoLike()
        testCryptoUnlike()
    }

    /// Test `Endpoint.News`.
    func testEndpointNews() {
        // Test inbox.
        func testInbox() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.News.inbox
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }

        testInbox()
    }

    /// Test `Endpoint.User`.
    func testEndpointUser() {
        // Test blocked.
        func testBlocked() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.User.blocked
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test summary.
        func testSummary() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.User.summary(for: secret.identifier)
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }
        // Test all.
        func testAll() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.User.all(matching: "instagram")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status.string()) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }

        testBlocked()
        testSummary()
        testAll()
    }

    /// Test location endpoints.
    func testEndpointLocation() {
        // Test search.
        func testSearch() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Location.around(coordinates: .init(latitude: 45.434272, longitude: 12.338509))
                .unlocking(with: secret)
                .task {
                    print($0)
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 30)
        }

        testSearch()
    }

    static var allTests = [
        ("Endpoint.Archive", testEndpointArchive),
        ("Endpoint.Direct", testEndpointDirect),
        ("Endpoint.Discover", testEndpointDiscover),
        ("Endpoint.Feed", testEndpointFeed),
        ("Endpoint.Friendship", testEndpointFriendship),
        ("Endpoint.Highlights", testEndpointHighlights),
        ("Endpoint.Media", testEndpointMedia),
        ("Endpoint.News", testEndpointNews),
        ("Endpoint.User", testEndpointUser),
        ("Endpoint.Location", testEndpointLocation)
    ]
}
