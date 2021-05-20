//
//  AvatarButton.swift
//  Followers
//
//  Created by Stefano Bertagno on 08/02/21.
//

import SwiftUI

import Swiftagram

/// A `struct` defining an image of a user.
internal struct AvatarImage: View {
    /// The pixel length.
    @Environment(\.pixelLength) var pixelLength: CGFloat

    /// The actual user.
    let user: User?

    /// The underlying view.
    var body: some View {
        Color(.quaternarySystemFill)
            // We implement the image as an overlay
            // to make sure the background is always
            // drawn.
            .overlay(user.flatMap(\.thumbnail).flatMap {
                RemoteImage(url: $0, placeholder: .init())
                    .scaledToFill()
            })
            .mask(Circle())
            .overlay(Circle().strokeBorder(Color(.opaqueSeparator), lineWidth: pixelLength))
    }
}

/// A `struct` defining a button with the logged in user image.
internal struct AvatarButton: View {
    /// The pixel length.
    @Environment(\.pixelLength) var pixelLength: CGFloat

    /// The actual user.
    let user: User?
    /// The action.
    let action: () -> Void

    /// The underlying view.
    var body: some View {
        Button(action: action) { AvatarImage(user: user).frame(width: 30, height: 30) }
    }
}
