//
//  Media+Content.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 23/08/21.
//

import Foundation

import Swiftagram

internal extension Media.Content {
    /// Fetch all images.
    func images() -> [Media.Version]? {
        switch self {
        case .picture(let picture):
            return picture.images
        case .video(let video):
            return video.images
        case .album(let album):
            return album.first?.images()
        default:
            return nil
        }
    }
}
