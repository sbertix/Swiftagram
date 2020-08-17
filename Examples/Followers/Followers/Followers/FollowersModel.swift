//
//  FollowersModel.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import Combine
import Foundation

import ComposableRequestCrypto
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
            guard let secret = secret, secret.id != oldValue?.id else { return }
            fetch(secret: secret)
        }
    }

    /// Subscriptions.
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Lifecycle
    /// Init.
    init() {
        // Fetch the current `Secret`.
        if let secret = ComposableRequestCrypto.KeychainStorage<Secret>().all().first {
            self.secret = secret
            self.current = UserDefaults.standard
                .data(forKey: secret.id)
                .flatMap { try? JSONDecoder().decode(User.self, from: $0) }
        }
        // Keep `UserDefaults` in sync.
        // This will only persist new `User`s, not delete old ones: this is just an example.
        $current.compactMap { $0 }
            .removeDuplicates(by: { $0.identifier == $1.identifier })
            .map { (data: try? JSONEncoder().encode($0), id: $0.identifier) }
            .sink { UserDefaults.standard.set($0.data, forKey: $0.id) }
            .store(in: &subscriptions)
    }

    /// Fetch values.
    func fetch(secret: Secret) {
        // Load info for the logged in user.
        Endpoint.User.summary(for: secret.id)
            .unlocking(with: secret)
            .publish()
            .map(\.user)
            .catch { _ in Empty() }
            .assign(to: \.current, on: self)
            .store(in: &subscriptions)
        // Load the first 3 pages of the current user's followers.
        // In a real app you might want to fetch all of them.
        followers = []
        Endpoint.Friendship.following(secret.id)
            .unlocking(with: secret)
            .publish()
            .prefix(3)
            .compactMap(\.users)
            .catch { _ in Empty() }
            .assign(to: \.appendFollowers, on: self)
            .store(in: &subscriptions)
    }
}
