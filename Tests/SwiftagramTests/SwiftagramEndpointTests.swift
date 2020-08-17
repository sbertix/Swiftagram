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

// swiftlint:disable superfluous_disable_command
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
// swiftlint:disable file_length
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
        Secret(cookies: [
            HTTPCookie(name: "ds_user_id", value: ProcessInfo.processInfo.environment["DS_USER_ID"]!),
            HTTPCookie(name: "sessionid", value: ProcessInfo.processInfo.environment["SESSIONID"]!),
            HTTPCookie(name: "csrftoken", value: ProcessInfo.processInfo.environment["CSRFTOKEN"]!),
            HTTPCookie(name: "rur", value: ProcessInfo.processInfo.environment["RUR"]!)
        ])
    }()

    /// Set up.
    override func setUp() {
        // Update the default `Requester`.
        Requester.default = .instagram
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
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test pending inbox.
        func testPendingThreads() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Direct.pendingThreads()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test presence.
        func testPresence() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Direct.presence
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test ranked recipients.
        func testRankedRecipients() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Direct.recipients()
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
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
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }

        testThreads()
        testPendingThreads()
        testPresence()
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
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
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
            wait(for: [completion, value], timeout: 60)
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
            wait(for: [completion, value], timeout: 60)
        }

        testUsers()
        testExplore()
        testTopics()
    }

    /// Test `Endpoint.Friendship`.
    func testEndpointFriendship() {
        // Test followed.
        func testFollowed() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.followed(by: secret.id)
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test following.
        func testFollowing() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.following(secret.id)
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test friendship.
        func testFriendship() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.summary(for: "25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test friendships.
        func testFriendships() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.summary(for: ["25025320"])
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
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
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test follow.
        func testFollow() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.follow("25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test unfollow.
        func testUnfollow() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Friendship.unfollow("25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }

        testFollowed()
        testFollowing()
        testFriendship()
        testFriendships()
        testPendingRequests()
        /*testFollow()
        testUnfollow()*/
    }

    /// Test `Endpoint.Highlights`.
    func testEndpointHighlights() {
        // Test highlights.
        func testHighlights() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Highlights.tray(for: secret.id)
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
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
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test permalink.
        func testPermalink() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.permalink(for: "2345240077849019656")
                .unlocking(with: secret)
                .task(by: .instagram) {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }

        testSummary()
        testPermalink()
    }

    /// Test `Endpoint.Media.Posts`.
    func testEndpointPosts() {
        // Test liked.
        func testLiked() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.liked()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test saved.
        func testSaved() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.saved()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test posts.
        func testPosts() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.by("25025320")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test user tags.
        func testUsertags() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.including("25025320")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test tag.
        func testTag() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.tagged(with: "instagram")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test likers.
        func testLikers() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.likers(for: "2345240077849019656")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test comments.
        func testComments() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.comments(for: "2345240077849019656")
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test crypto like.
        func testCryptoLike() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.like("2345240077849019656")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test crypto unlike.
        func testCryptoUnlike() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.unlike("2345240077849019656")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test crypto archive.
        func testCryptoArchive() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.archive("2365553117501809247_7271269732")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test crypto unarchive.
        func testCryptoUnarchive() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.unarchive("2365553117501809247_7271269732")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test save.
        func testSave() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.save("2363340238886161192_25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test unsave.
        func testUnsave() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.unsave("2363340238886161192_25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test like comment
        func testLikeComment() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.like(comment: "17885013160654942")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test unlike comment.
        func testUnlikeComment() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Posts.unlike(comment: "17885013160654942")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test post and delete image.
        func testPostThenDeleteImage() {
            let post = XCTestExpectation()
            let delete = XCTestExpectation()
            // upload.
            var optionalIdentifier: NSString?
            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            Endpoint.Media.Posts.upload(image: NSColor.blue.image(sized: .init(width: 640, height: 640)), captioned: nil)
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    optionalIdentifier = (try? $0.get().media?.identifier).flatMap { $0 as NSString }
                    post.fulfill()
                }
                .resume()
            #elseif canImport(UIKit)
            guard let image = UIImage(color: .red, size: .init(width: 640, height: 640)) else {
                return XCTFail("Unable to generate `UIImage` from `UIColor`.")
            }
            Endpoint.Media.Posts.upload(image: image, captioned: nil)
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    optionalIdentifier = (try? $0.get().media?.identifier).flatMap { $0 as NSString }
                    post.fulfill()
                }
                .resume()
            #else
            post.fulfill()
            #endif
            // wait for expectations.
            wait(for: [post], timeout: 60)
            // delete.
            guard let identifier = optionalIdentifier else {
                return XCTFail("Cannot delete a picture without a valid identifier.")
            }
            Endpoint.Media.Posts.delete(matching: identifier as String)
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok" || (try? $0.get().spam.bool()) == true)
                    delete.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [delete], timeout: 60)
        }

        testLiked()
        testSaved()
        testPosts()
        testUsertags()
        testTag()
        testLikers()
        testComments()
        testSave()
        testUnsave()
        testCryptoLike()
        testCryptoUnlike()
        testCryptoArchive()
        testCryptoUnarchive()
        testLikeComment()
        testUnlikeComment()
        testPostThenDeleteImage()
    }

    /// Test `Endpoint.Media.Stories`.
    func testEndpointStories() {
        // Test followed.
        func testFollowed() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Stories.followed
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test archive.
        func testArchive() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Stories.archived()
                .unlocking(with: secret)
                .task(
                    maxLength: 1,
                    onComplete: {
                        XCTAssert($0 == 1)
                        completion.fulfill()
                    },
                    onChange: {
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test stories.
        func testStories() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Media.Stories.by("25025320")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }

        testFollowed()
        testArchive()
        testStories()
    }

    /// Test `Endpoint.News`.
    func testEndpointNews() {
        // Test inbox.
        func testInbox() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.News.recent
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status.string()) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
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
            wait(for: [completion, value], timeout: 60)
        }
        // Test summary.
        func testSummary() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.User.summary(for: secret.id)
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
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
                        XCTAssert((try? $0.get().status) == "ok")
                        value.fulfill()
                    }
                )
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
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
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test summary.
        func testSummary() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Location.summary(for: "189075947904164")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }
        // Test story.
        func testStory() {
            let completion = XCTestExpectation()
            let value = XCTestExpectation()
            // fetch.
            Endpoint.Location.stories(at: "189075947904164")
                .unlocking(with: secret)
                .task {
                    XCTAssert((try? $0.get().status) == "ok")
                    value.fulfill()
                    completion.fulfill()
                }
                .resume()
            // wait for expectations.
            wait(for: [completion, value], timeout: 60)
        }

        testSearch()
        testSummary()
        testStory()
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
// swiftlint:enable function_body_length
// swiftlint:enable type_body_length
// swiftlint:enable file_lengths
// swiftlint:enable superfluous_disable_command

#if canImport(UIKit)
// An extension generating a `UIImage` from a `UIColor`.
extension UIImage {
    convenience init?(color: UIColor, size: CGSize = .init(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
#elseif canImport(AppKit)
// An extension generating a `NSImage` from a `NSColor`.
extension NSColor {
    func image(sized size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        drawSwatch(in: .init(origin: .zero, size: size))
        image.unlockFocus()
        return image
    }
}
#endif
