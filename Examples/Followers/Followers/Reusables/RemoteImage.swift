//
//  RemoteImage.swift
//  Followers
//
//  Created by Stefano Bertagno on 08/02/21.
//

import SwiftUI
import UIKit

import FetchImage

/// A `struct` displaying a remote image.
internal struct RemoteImage: View {
    /// The current image.
    @StateObject private var image: FetchImage = .init()

    /// The underlying url.
    var url: URL?
    /// The placeholder.
    var placeholder: UIImage

    /// The underlying view.
    var body: some View {
        (image.view ?? Image(uiImage: placeholder))
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .animation(.default)
            .onAppear { if let url = url { image.load(url) } }
            .onDisappear(perform: image.cancel)
    }

    /// Init.
    /// - parameters:
    ///     - url: An optional `URL`.
    ///     - placeholder: A valid `UIImage`.
    init(url: URL?, placeholder: UIImage) {
        self.url = url
        self.placeholder = placeholder
    }
}
