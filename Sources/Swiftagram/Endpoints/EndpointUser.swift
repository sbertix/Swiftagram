//
//  EndpointUser.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A module-like `enum` holding reference to `users` `Endpoint`s. Requires authentication.
    enum User {
        /// The base endpoint.
        private static let base = Endpoint.version1.users.appendingDefaultHeader()

        /// A list of all profiles blocked by the user.
        public static var blocked: Disposable<Wrapper> {
            .init { secret, session in
                Deferred {
                    base.blocked_list
                        .header(secret.header)
                        .session(session)
                        .map(\.data)
                        .wrap()
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// A user matching `identifier`'s info.
        /// 
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func summary(for identifier: String) -> Disposable<Swiftagram.User.Unit> {
            .init { secret, session in
                Deferred {
                    base.path(appending: identifier)
                        .info
                        .header(secret.header)
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.User.Unit.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// All user matching `query`.
        ///
        /// - parameter query: A `String` holding reference to a valid user query.
        public static func all(matching query: String) -> Paginated<Swiftagram.User.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    base.search
                        .header(appending: secret.header)
                        .header(appending: rank, forKey: "rank_token")
                        .query(appending: ["q": query, "max_id": next])
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.User.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }
    }
}
