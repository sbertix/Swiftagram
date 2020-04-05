//
//  User.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import Foundation

/// A `struct` holding reference to a user's basic info.
struct User: Codable {
    /// The username.
    var username: String
    /// The full name.
    var name: String?
    /// The avatar.
    var avatar: URL?
}
