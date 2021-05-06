//
//  Color.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 26/08/20.
//

import Foundation

#if canImport(UIKit)

import UIKit

typealias Color = UIColor

extension UIColor {
    /// Compose an image with a given size.
    ///
    /// - parameter size: A valid `CGSize`.
    /// - returns: A valid `UIImage`.
    func image(sized size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        self.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(cgImage: image!.cgImage!)
    }
}

#elseif canImport(AppKit)

import AppKit

typealias Color = NSColor

extension NSColor {
    /// Compose an image with a given size.
    ///
    /// - parameter size: A valid `CGSize`.
    /// - returns: A valid `NSImage`.
    func image(sized size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        drawSwatch(in: .init(origin: .zero, size: size))
        image.unlockFocus()
        return image
    }
}

#endif
