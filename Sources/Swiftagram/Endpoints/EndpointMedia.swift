//
//  EndpointMedia.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A module-like `enum` holding reference to `media` `Endpoint`s. Requires authentication.
    enum Media {
        /// The base endpoint.
        static let base = Endpoint.version1.media.appendingDefaultHeader()

        /// A media matching `identifier`'s info.
        ///
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func summary(for identifier: String) -> Disposable<Swiftagram.Media.Collection, Error> {
            .init { secret, session in
                Deferred {
                    base.path(appending: identifier)
                        .info
                        .header(appending: secret.header)
                        .publish(with: session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.Media.Collection.init)
                }
                .eraseToAnyPublisher()
            }
        }

        /// The permalinkg for the media matching `identifier`.
        ///
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func permalink(for identifier: String) -> Disposable<Wrapper, Error> {
            .init { secret, session in
                Deferred {
                    base.path(appending: identifier)
                        .permalink
                        .header(appending: secret.header)
                        .publish(with: session)
                        .map(\.data)
                        .wrap()
                }
                .eraseToAnyPublisher()
            }
        }
    }
}
