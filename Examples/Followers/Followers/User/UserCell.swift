//
//  UserCell.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import SwiftUI

import FetchImage

/// A `struct` displaying a remote image.
struct RemoteImage: View {
    /// The current image.
    @ObservedObject var image: FetchImage
    /// The placeholder.
    var placeholder: UIImage

    /// Init.
    /// - parameters:
    ///     - url: An optional `URL`.
    ///     - placeholder: A valid `UIImage`.
    init(url: URL?, placeholder: UIImage) {
        self.image = FetchImage(url: url ?? URL(string: "https://example.com")!)
        self.placeholder = placeholder
    }

    var body: some View {
        (image.view ?? Image(uiImage: placeholder))
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .animation(.default)
            .onAppear(perform: image.fetch)
            .onDisappear(perform: image.cancel)
    }
}

/// A `struct` displaying a `User`.
struct UserCell: View {
    /// A valid `User`.
    var user: User

    /// The actual body.
    var body: some View {
        HStack {
            // The image or a placeholder.
            if user.avatar != nil {
                user.avatar.flatMap {
                    RemoteImage(url: $0, placeholder: UIImage(named: "placeholder") ?? .init())
                        .frame(width: 44, height: 44)
                        .mask(Circle())
                        .shadow(radius: 1)
                }
            } else {
                SwiftUI.Image("placeholder")
                    .frame(width: 44, height: 44)
                    .mask(Circle())
                    .shadow(radius: 1)
            }
            // The username and name.
            VStack(alignment: .leading) {
                Text(user.username).font(.headline)
                if user.name != nil {
                    user.name.flatMap(Text.init)?.font(.footnote).foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
