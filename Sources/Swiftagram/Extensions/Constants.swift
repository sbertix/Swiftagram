//
//  Constants.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 05/04/2020.
//

import Foundation

/// A `struct` holding reference to API constants.
public struct Constants {
    /// The app version.
    public static let api = "128.0.0.26.128"
    /// The app code.
    public static let code = "197825254"

    /// The signature key.
    internal static let signatureKey = "937463b5272b5d60e9d20f0f8d7d192193dd95095a3ad43725d494300a5ea5fc"
    /// The signature version.
    internal static let signatureVersion = "5"
}

/// A `struct` holding reference to the API supported capabilities.
internal struct SupportedCapabilities {
    /// A shared `Dictionary` of `String`s.
    internal static let `default` = [
        "SUPPORTED_SDK_VERSIONS": ["13.0", "14.0", "15.0", "16.0", "17.0", "18.0", "19.0",
                                   "20.0", "21.0", "22.0", "23.0", "24.0", "25.0", "26.0",
                                   "27.0", "28.0", "29.0", "30.0", "31.0", "32.0", "33.0",
                                   "34.0", "35.0", "36.0", "37.0", "38.0", "39.0", "40.0",
                                   "41.0", "42.0", "43.0", "44.0", "45.0", "46.0", "47.0",
                                   "48.0", "49.0", "50.0", "51.0", "52.0", "53.0", "54.0",
                                   "55.0", "56.0", "57.0", "58.0"].joined(separator: ","),
        "FACE_TRACKER_VERSION": "12",
        "segmentation": "segmentation_enabled",
        "COMPRESSION": "ETC2_COMPRESSION",
        "world_tracker": "world_tracker_enabled",
        "gyroscope": "gyroscope_enabled"
    ]
}
