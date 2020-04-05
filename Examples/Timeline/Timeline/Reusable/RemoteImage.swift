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

    var url: URL?
    let placeholder: UIImage
    var transition: AnyTransition = .opacity

    var body: some View {
        if let url = url {
            ImagePipeline.shared.loadImage(with: url) { result in
                switch result {
                case .success(let response): self.uiImage = response.image
                case .failure(let error): print(error)
                }
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
