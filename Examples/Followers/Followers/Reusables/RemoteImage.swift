//
//  RemoteImage.swift
//  Followers
//
//  Created by Stefano Bertagno on 08/02/21.
//  Copyright © 2021 Stefano Bertagno. All rights reserved.
//

import SwiftUI
import UIKit

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
