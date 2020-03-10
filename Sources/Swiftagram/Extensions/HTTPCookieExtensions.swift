//
//  HTTPCookieExtensions.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

/// An `HTTPCookie` extension allowing for archiving.
public extension HTTPCookie {
    /// Store as `Data`.
    var data: Data {
        if #available(iOS 11, OSX 10.13, tvOS 11, watchOS 4, *) {
            return (try? NSKeyedArchiver.archivedData(withRootObject: properties ?? [:],
                                                      requiringSecureCoding: true)) ?? .init()
        } else {
            return NSKeyedArchiver.archivedData(withRootObject: properties ?? [:])
        }
    }
    
    /// Init with `data`.
    convenience init?(data: Data) {
        if #available(iOS 11, OSX 10.13, tvOS 11, watchOS 4, *) {
            guard let properties = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? [HTTPCookiePropertyKey: Any] else {
                return nil
            }
            self.init(properties: properties)
        } else {
            self.init(properties: NSKeyedUnarchiver.unarchiveObject(with: data) as? [HTTPCookiePropertyKey: Any] ?? [:])
        }
    }
}
