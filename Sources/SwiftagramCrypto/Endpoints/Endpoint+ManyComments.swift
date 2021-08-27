//
//  Endpoint+ManyComments.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

public extension Endpoint.Group.Media.ManyComments {
    /// Delete all selected comments.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func delete() -> Endpoint.Single<Status> {
        .init { secret, requester in
            Request.media
                .path(appending: self.media.identifier)
                .path(appending: "comment/bulk_delete/")
                .header(appending: secret.header)
                .signing(body: [
                    "comment_ids_to_delete": self.identifiers.joined(separator: ","),
                    "_csrftoken": secret["csrftoken"],
                    "_uid": secret.identifier,
                    "_uuid": secret.client.device.identifier.uuidString
                ])
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Status.init)
                .requested(by: requester)
        }
    }
}
