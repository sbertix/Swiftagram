//
//  Endpoint+Tag.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 20/04/21.
//

import Foundation

public extension Endpoint.Group.Tag {
    /// Follow the current tag.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func follow() -> Endpoint.Single<Status, Error> {
        .init { secret, session in
            Deferred {
                Request.version1
                    .tags
                    .follow
                    .path(appending: self.name)
                    .path(appending: "/")
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .signing(body: ["_csrftoken": secret["csrftoken"],
                                    "_uid": secret.identifier,
                                    "_uuid": secret.client.device.identifier.uuidString])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Status.init)
            }
            .replaceFailingWithError()
        }
    }

    /// Unfollow the current tag.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unfollow() -> Endpoint.Single<Status, Error> {
        .init { secret, session in
            Deferred {
                Request.version1
                    .tags
                    .unfollow
                    .path(appending: self.name)
                    .path(appending: "/")
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .signing(body: ["_csrftoken": secret["csrftoken"],
                                    "_uid": secret.identifier,
                                    "_uuid": secret.client.device.identifier.uuidString])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Status.init)
            }
            .replaceFailingWithError()
        }
    }
}
