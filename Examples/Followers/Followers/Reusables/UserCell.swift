//
//  UserCell.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//

import SwiftUI

import Swiftagram

/// A `struct` defining a `FollowersView` row.
internal struct UserCell: View {
    /// A valid `User`.
    let user: User

    /// The actual body.
    var body: some View {
        HStack(spacing: 15) {
            // The user image.
            AvatarImage(user: user).frame(width: 44, height: 44)
            VStack(alignment: .leading) {
                // The username.
                Text(user.username).font(.headline).fixedSize(horizontal: false, vertical: true)
                // The actual name.
                if let name = user.name?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !name.isEmpty {
                    Text(name)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            // The chevron.
            Spacer()
            Image(systemName: "chevron.right")
                .imageScale(.small)
                .foregroundColor(.secondary)
        }
    }
}
