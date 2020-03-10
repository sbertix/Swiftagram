//
//  FollowersModel.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import Combine
import Foundation

import KeychainSwift
import Swiftagram

/// An `ObservableObject` dealing with requests.
final class FollowersModel: ObservableObject {
    /// The logged in user.
    @Published var current: User?
    /// Initial followers for the logged in user.
    @Published var followers: [User]?
    /// The logged in secret.
    var secret: Secret? {
        didSet {
            guard let secret = secret, secret.id != oldValue?.id else { return }
            fetch(secret: secret)
        }
    }
    
    /// Cancellable for user's info.
    var userCancellable: AnyCancellable?
    /// Cancellable for followers.
    var followersCancellable: AnyCancellable?
    
    // MARK: Lifecycle
    /// Init.
    init() { start() }
    
    @discardableResult
    /// Check for `Secret` in `KeychainStorage`.
    /// - returns: `true` if it was started, `false` otherwise.
    func start() -> Bool {
        print(KeychainSwift(keyPrefix: "swiftagram").allKeys)
        // Check for `Secret` in `KeychainStorage`.
        guard let secret = KeychainStorage().all().first else { return false }
        self.secret = secret
        self.current = UserDefaults.standard
            .data(forKey: secret.id)
            .flatMap { try? JSONDecoder().decode(User.self, from: $0) }
        return true
    }
    /// Fetch values.
    func fetch(secret: Secret) {
        // Load info for the logged in user.
        userCancellable = Request(Endpoint.User.summary(for: secret.id))
            .authenticating(with: secret)
            .responsePublisher()
            .map {
                guard let username = $0.user.username.string else { return nil }
                return User(username: username,
                            name: $0.user.fullName.string,
                            avatar: $0.user.profilePicUrl.url)
            }
            .catch { _ in Empty() }
            .assign(to: \.current, on: self)
        // Load the first set of followers.
        followersCancellable = Request(Endpoint.Friendship.following(secret.id))
            .authenticating(with: secret)
            .responsePublisher()
            .map {
                $0.users
                    .array?
                    .compactMap {
                        guard let username = $0.username.string else { return nil }
                        return User(username: username,
                                    name: $0.fullName.string.flatMap {
                                        let name = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                                        return name.isEmpty ? nil : name
                            },
                                    avatar: $0.profilePicUrl.url)
                    } ?? []
            }
            .catch { _ in Empty() }
            .assign(to: \.followers, on: self)
    }
}
