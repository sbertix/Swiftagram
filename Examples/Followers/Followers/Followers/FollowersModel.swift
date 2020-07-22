//
//  FollowersModel.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import Combine
import Foundation

import Swiftagram
import SwiftagramCrypto

/// An `ObservableObject` dealing with requests.
final class FollowersModel: ObservableObject {
    /// The logged in user.
    @Published var current: User?
    /// Initial followers for the logged in user.
    @Published var followers: [User]?
    /// Append followers.
    var appendFollowers: [User] {
        get { [] }
        set { followers?.append(contentsOf: newValue) }
    }
    /// The logged in secret.
    var secret: Secret? {
        didSet {
            guard let secret = secret, secret.identifier != oldValue?.identifier else { return }
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

    /// Check for `Secret` in `KeychainStorage`.
    /// - returns: `true` if it was started, `false` otherwise.
    @discardableResult
    func start() -> Bool {
        // Check for `Secret` in `KeychainStorage`.
        guard let secret = KeychainStorage().all().first else { return false }
        self.secret = secret
        self.current = UserDefaults.standard
            .data(forKey: secret.identifier)
            .flatMap { try? JSONDecoder().decode(User.self, from: $0) }
        return true
    }
    /// Fetch values.
    func fetch(secret: Secret) {
        // Load info for the logged in user.
        userCancellable = Endpoint.User.summary(for: secret.identifier)
            .unlocking(with: secret)
            .publish()
            .map {
                guard let username = $0.user.username.string() else { return nil }
                return User(username: username,
                            name: $0.user.fullName.string(),
                            avatar: $0.user.profilePicUrl.url())
            }
            .handleEvents(receiveOutput: {
                $0.flatMap { try? JSONEncoder().encode($0) }
                    .flatMap { UserDefaults.standard.set($0, forKey: secret.identifier) }
                UserDefaults.standard.synchronize()
            })
            .catch { _ in Empty() }
            .assign(to: \.current, on: self)
        // Load the first set of followers.
        followers = []
        followersCancellable = Endpoint.Friendship.following(secret.identifier)
            .unlocking(with: secret)
            .publish()
            .prefix(3)
            .map {
                $0.users
                    .array()?
                    .compactMap {
                        guard let username = $0.username.string() else { return nil }
                        return User(username: username,
                                    name: $0.fullName.string().flatMap {
                                        let name = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                                        return name.isEmpty ? nil : name
                            },
                                    avatar: $0.profilePicUrl.url())
                    } ?? []
            }
            .catch { error -> Empty<[User], Never> in print(error); return Empty() }
            .assign(to: \.appendFollowers, on: self)
    }
}
