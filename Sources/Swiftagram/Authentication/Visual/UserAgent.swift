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
    /// Defaults to `Device.default.browserUserAgent`.
    case `default`
    /// Tied to a specific iOS version, e.g. `13_4_1`.
    /// - warning: You won't be able to use encrypted endpoints (e.g. `Endpoint.Friendship.follow`).
    case iOS(version: String)
    /// An entirely custom user agent.
    /// - warning: You won't be abled to use encrypted endpoints (e.g. `Endpoint.Friendship.follow`), unless the user agent is of an Android device.
    case custom(String)

    #if !targetEnvironment(macCatalyst) && os(iOS) && canImport(UIKit)
    /// Tied to the current iOS version.
    /// - warning: You won't be able to use encrypted endpoints (e.g. `Endpoint.Friendship.follow`).
    case current
    #endif

    /// Compute the User Agent.
    /// - returns: A valid `String` representing a User Agent.
    internal var string: String {
        switch self {
        case .default: return Client.default.browserDescription
        case .custom(let string): return string
        case .iOS(let version):
            return ["Mozilla/5.0 (iPhone; CPU iPhone OS",
                    version,
                    "like Mac OS X)",
                    "AppleWebKit/605.1.15 (KHTML, like Gecko)",
                    "Mobile/15E148"].joined(separator: " ")
        #if !targetEnvironment(macCatalyst) && os(iOS) && canImport(UIKit)
        case .current: return UserAgent.iOS(version: UIDevice.current.systemVersion).string
        #endif
        }
    }
}
