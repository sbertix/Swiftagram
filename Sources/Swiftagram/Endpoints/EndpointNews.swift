//
//  EndpointNews.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A module-like `enum` holding reference to `news` `Endpoint`s. Requires authentication.
    enum News {
        /// The base endpoint.
        private static let base = Endpoint.version1.news.appendingDefaultHeader()

        /// Latest news.
        public static var recent: Disposable<Wrapper> {
            .init { secret, session in
                Projectables.Deferred {
                    base.inbox
                        .header(appending: secret.header)
                        .project(session)
                        .map(\.data)
                        .wrap()
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }
    }
}
