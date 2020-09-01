//
//  Agnostic.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 01/09/20.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// A `struct` holding reference to "framework agnostic" types.
public struct Agnostic {
    #if canImport(UIKit)
    /// `UIImage`.
    public typealias Image = UIImage
    /// `UIColor`.
    public typealias Color = UIColor
    #elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// `NSImage`.
    public typealias Image = NSImage
    /// `NSColor`.
    public typealias Color = NSColor
    #endif
}

#if canImport(UIKit)
/// An extension for `UIImage` generation from `UIColor`.
public extension UIColor {
    /// Create a solid color `UIImage`.
    func image(size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        self.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(cgImage: image!.cgImage!)
    }
}
/// An extension for `UIImage`s.
public extension UIImage {
    /// Compute the `.jpeg` representation.
    func jpegRepresentation() -> Data? { jpegData(compressionQuality: 1) }
}
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
/// An extension for `NSImage` generation from `NSColor`.
public extension NSColor {
    /// Create a solid color `NSImage`.
    func image(size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        drawSwatch(in: .init(origin: .zero, size: size))
        image.unlockFocus()
        return image
    }
}
/// An extension for `NSImage`s.
public extension NSImage {
    /// Compute the `.jpeg` representation.
    func jpegRepresentation() -> Data? {
        cgImage(forProposedRect: nil, context: nil, hints: nil)
            .flatMap(NSBitmapImageRep.init)?
            .representation(using: .jpeg, properties: [:])
    }
}
#endif
