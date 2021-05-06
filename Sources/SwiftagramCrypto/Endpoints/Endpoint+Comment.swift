//
//  Endpoint+Comment.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

public extension Endpoint.Group.Media.Comment {
    /// Delete the current comment.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func delete() -> Endpoint.Single<Status, Error> {
        media.comments([identifier]).delete()
    }
}
