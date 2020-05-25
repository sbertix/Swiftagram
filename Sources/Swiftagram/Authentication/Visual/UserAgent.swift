//
//  UserAgent.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 25/05/2020.
//

import Foundation

#if !targetEnvironment(macCatalyst) && os(iOS) && canImport(UIKit)
import UIKit
#endif

/// An `enum` holding reference to custom User Agents.
public enum UserAgent {
    /// Defaults to `iOS(version: "13_1_3")`.
    case `default`
    /// Tied to a specific iOS version, e.g. `13_1_3`.
    case iOS(version: String)
    /// An entirely custom user agent.
    /// - warning: This is not guaranteed to work.
    case custom(String)

    #if !targetEnvironment(macCatalyst) && os(iOS) && canImport(UIKit)
    /// Tied to the current iOS version.
    case current
    #endif

    /// Compute the User Agent.
    /// - returns: A valid `String` representing a User Agent.
    internal var string: String {
        switch self {
        case .default: return UserAgent.iOS(version: "13_1_3").string
        case .custom(let string): return string
        case .iOS(let version):
            return ["Mozilla/5.0 (iPhone; CPU iPhone OS",
                    version,
                    "like Mac OS X)",
                    "AppleWebKit/605.1.15 (KHTML, like Gecko)",
                    "Version/13.0.1 Mobile/15E148 Safari/604.1"].joined(separator: " ")
        #if !targetEnvironment(macCatalyst) && os(iOS) && canImport(UIKit)
        case .current: return UserAgent.iOS(version: UIDevice.current.systemVersion).string
        #endif
        }
    }
}
