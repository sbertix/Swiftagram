//
//  Post.swift
//  Timeline
//
//  Created by Stefano Bertagno on 05/04/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import CoreGraphics
import Foundation

/// A `struct` holding reference to a user's basic post.
struct Post: Codable, Identifiable {
    /// A `struct` holding reference to videos and pics.
    struct Media: Codable {
        /// The preview url.
        var preview: URL?
        /// The video url.
        var video: URL?
        /// The size.
        var size: CGSize
        
        /// The aspect ratio.
        var aspectRatio: CGFloat { return size.width/size.height }
    }
    
    /// The id.
    var id: String
    /// The media.
    var media: [Media]
    /// The caption.
    var caption: String?
    /// The user.
    var user: User
}
