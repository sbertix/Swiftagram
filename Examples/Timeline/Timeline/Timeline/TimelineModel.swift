//
//  TimelineModel.swift
//  Timeline
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import Combine
import Foundation

import ComposableRequest
import Swiftagram
import SwiftagramKeychain

/// An `ObservableObject` dealing with requests.
final class TimelineModel: ObservableObject {
    /// The logged in user.
    @Published var current: User?
    /// Initial posts.
    @Published var posts: [Post]?
    /// Append posts.
    var appendPosts: [Post] {
        get { [] }
        set { posts = (posts ?? [])+newValue }
    }
    /// The logged in secret.
    var secret: Swiftagram.Secret? {
        didSet {
            guard let secret = secret, secret.id != oldValue?.id else { return }
            fetch(secret: secret)
        }
    }

    /// Cancellable for user's info.
    private var userCancellable: AnyCancellable?
    /// Timeline task.
    private var timeline: Requester.Task?
    /// Next max id.
    private var nextMaxId: String?
    /// Loading.
    @Published private(set) var isLoading: Bool = false

    // MARK: Lifecycle
    /// Init.
    init() { start() }

    /// Check for `Secret` in `KeychainStorage`.
    /// - returns: `true` if it was started, `false` otherwise.
    @discardableResult
    func start() -> Bool {
        // Check for `Secret` in `KeychainStorage`.
        guard let secret = KeychainStorage().all().first else { return false }
        self.secret = secret
        self.current = UserDefaults.standard
            .data(forKey: secret.id)
            .flatMap { try? JSONDecoder().decode(User.self, from: $0) }
        return true
    }

    /// Fetch values.
    private func fetch(secret: Swiftagram.Secret) {
        // Load info for the logged in user.
        userCancellable = Endpoint.User.summary(for: secret.id)
            .authenticating(with: secret)
            .publish()
            .map {
                guard let username = $0.user.username.string() else { return nil }
                return User(username: username,
                            name: $0.user.fullName.string(),
                            avatar: $0.user.profilePicUrl.url())
            }
            .handleEvents(receiveOutput: {
                $0.flatMap { try? JSONEncoder().encode($0) }
                    .flatMap { UserDefaults.standard.set($0, forKey: secret.id) }
                UserDefaults.standard.synchronize()
            })
            .catch { _ in Empty() }
            .assign(to: \.current, on: self)
        // Load the first set of followers.
        nextMaxId = nil
        posts = nil
        next()
    }

    /// Load next page.
    func next() {
        guard !isLoading, let secret = secret else { return }
        guard (nextMaxId == nil && posts == nil) || nextMaxId != nil else { return }
        // update posts.
        isLoading = true
        timeline = Endpoint.Feed.timeline
            .header("reason", value: nextMaxId == nil ? "cold_start_fresh" : "pagination")
            .body("max_id", value: nextMaxId)
            .initial(nextMaxId)
            .authenticating(with: secret)
            .cycleTask(maxLength: 2) { [weak self] in
                guard let response = try? $0.get() else { return }
                self?.nextMaxId = response.nextMaxId.string()
                self?.isLoading = false
                self?.appendPosts = response.feedItems
                    .array()?
                    .compactMap { item -> Post? in
                        let media = item.mediaOrAd
                        guard media.dictionary() != nil, media.adMetadata.dictionary() == nil, media.drAdType.int() == nil else { return nil }
                        // check for carousel media.
                        if let carousel = media.carouselMedia.array() {
                            return .init(id: media.pk.string() ?? "",
                                         media: carousel.map {
                                            return Post.Media(preview: $0.imageVersions2
                                                .candidates
                                                .array()?
                                                .first?["url"]
                                                .string()
                                                .flatMap { URL(string: $0) },
                                                              video: $0.videoVersions
                                                                .candidates
                                                                .array()?
                                                                .first?["url"]
                                                                .string()
                                                                .flatMap { URL(string: $0) },
                                                              size: .init(width: $0.originalWidth.int() ?? 100,
                                                                          height: $0.originalHeight.int() ?? 100))
                                },
                                         caption: media.caption.text.string(),
                                         user: User(username: media.user.username.string() ?? "———",
                                                    name: media.user.fullName.string(),
                                                    avatar: media.user.profilePicUrl.url()))
                        } else {
                            return .init(id: media.pk.string() ?? "",
                                         media: [Post.Media(preview: media.imageVersions2
                                            .candidates
                                            .array()?
                                            .first?["url"]
                                            .string()
                                            .flatMap { URL(string: $0) },
                                                            video: media.videoVersions
                                                                .candidates
                                                                .array()?
                                                                .first?["url"]
                                                                .string()
                                                                .flatMap { URL(string: $0) },
                                                            size: .init(width: media.originalWidth.int() ?? 100,
                                                                        height: media.originalHeight.int() ?? 100))],
                                         caption: media.caption.text.string(),
                                         user: User(username: media.user.username.string() ?? "———",
                                                    name: media.user.fullName.string(),
                                                    avatar: media.user.profilePicUrl.url()))
                        }
                    } ?? []
            }
            .resume()
    }
}
