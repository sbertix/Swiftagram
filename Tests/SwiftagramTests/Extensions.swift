//
//  Extensions.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 26/08/20.
//

import Foundation

extension HTTPCookie {
   /// Test.
   convenience init(name: String, value: String?) {
       self.init(properties: [.name: name,
                              .value: value ?? name,
                              .path: "",
                              .domain: ""])!
   }
}

#if canImport(UIKit)
import UIKit
typealias Color = UIColor
// An extension generating a `UIImage` from a `UIColor`.
extension UIColor {
   func image(sized size: CGSize) -> UIImage {
       let rect = CGRect(origin: .zero, size: size)
       UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
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
// An extension generating a `NSImage` from a `NSColor`.
extension NSColor {
   func image(sized size: CGSize) -> NSImage {
       let image = NSImage(size: size)
       image.lockFocus()
       drawSwatch(in: .init(origin: .zero, size: size))
       image.unlockFocus()
       return image
   }
}
#endif
