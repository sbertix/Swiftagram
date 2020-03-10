//
//  UserCell.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import SwiftUI
import UIKit

import Nuke

/// A `struct` displaying a remote image.
struct RemoteImage: View, Equatable {
    @State private var uiImage: UIImage?

    var url: URL
    let placeholder: UIImage
    var transition: AnyTransition = .opacity

    var body: some View {
        ImagePipeline.shared.loadImage(with: self.url) { result in
            switch result {
            case .success(let response): self.uiImage = response.image
            case .failure(let error): print(error)
            }
        }
        return Image(uiImage: uiImage ?? placeholder)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .transition(transition)
    }

    static func == (lhs: RemoteImage, rhs: RemoteImage) -> Bool {
        lhs.url == rhs.url
            && (lhs.uiImage == rhs.uiImage
                || (lhs.uiImage == nil && rhs.uiImage == nil && lhs.placeholder == rhs.placeholder))
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
