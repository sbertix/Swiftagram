//
//  FollowersModel.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

import SwiftagramCrypto

/// An `ObservableObject` dealing with requests.
final class FollowersModel: ObservableObject {
    /// The logged in user.
    @Published private(set) var current: User?
    /// Initial followers for the logged in user.
    @Published private(set) var followers: [User]?

    /// The current secret.
    private let secret: CurrentValueSubject<Secret?, Never> = .init(try? Authenticator.keychain.secrets.get().first)
    /// The dispose bag.
    private var bin: Set<AnyCancellable> = []

    /// Init.
    init() {
        // Update current `User` every time secret is.
        // In a real app you would cache this.
        secret.removeDuplicates(by: { $0?.identifier == $1?.identifier })
            .flatMap { secret -> AnyPublisher<User?, Never> in
                guard let secret = secret else { return Just(nil).eraseToAnyPublisher() }
                // Fetch the user.
                return Endpoint.user(secret.identifier)
                    .unlock(with: secret)
                    .session(.instagram)
                    .map(\.user)
                    .catch { _ in Just(nil) }
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .assign(to: \.current, on: self)
            .store(in: &bin)

        // Update followers.
        // We only load the first 3 pages.
        secret.removeDuplicates(by: { $0?.identifier == $1?.identifier })
            .flatMap { secret -> AnyPublisher<[User]?, Never> in
                guard let secret = secret else { return Just(nil).eraseToAnyPublisher() }
                // Fetch followers.
                return Endpoint.user(secret.identifier)
                    .followers
                    .unlock(with: secret)
                    .session(.instagram)
                    .pages(3)
                    .compactMap(\.users)
                    //swiftlint:disable reduce_into
                    .reduce([], +)
                    //swiftlint:enable reduce_into
                    .map(Optional.some)
                    .catch { _ in Just(nil) }
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .assign(to: \.followers, on: self)
            .store(in: &bin)
    }

    // MARK: Authentication

    /// Whether it's authenticated or not.
    var shouldPresentLoginView: Binding<Bool> {
        .init(get: { self.secret.value == nil }, set: { _ in })
    }

    /// Update the current `Secret`.
    ///
    /// - parameter secret: A valid `Secret`.
    func authenticate(with secret: Secret) {
        guard secret.identifier != self.secret.value?.identifier else { return }
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.secret.send(secret)
        }
    }

    /// Log out.
    func logOut() {
        guard let secret = secret.value else { return }
        do { try Authenticator.keychain.secret(secret.identifier).delete() } catch { print(error) }
        self.secret.send(nil)
    }
}
