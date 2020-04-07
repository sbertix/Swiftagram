//
//  PostView.swift
//  Timeline
//
//  Created by Stefano Bertagno on 05/04/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import SwiftUI

/// A `struct` defining a `View` displaying a timeline `Post`.
struct PostView: View {
    /// The pixel length.
    @Environment(\.pixelLength) var pixelLength
    /// A valid `Post`.
    var post: Post

    /// Init.
    init(post: Post) { self.post = post }

    /// The actual body.
    var body: some View {
        VStack(alignment: .leading) {
            // The user.
            UserView(user: post.user)
            // The actual preview.
            RemoteImage(url: post.media.first?.preview, placeholder: .init())
                .scaledToFit()
                .background(LinearGradient(gradient: .init(colors: [.orange, .pink]),
                                           startPoint: .top,
                                           endPoint: .bottom))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: pixelLength))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            // The caption.
            post.caption.flatMap(Text.init)?
                .foregroundColor(.secondary)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 4)
        }
        .padding(.bottom, 15)
        .padding(.top, 10)
        .padding(.horizontal)
        .fixedSize(horizontal: false, vertical: true)
        .overlay(Divider(), alignment: .bottom)
    }
}
