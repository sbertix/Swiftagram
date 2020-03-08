//
//  Headers.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `struct` holding reference to keys and values.
internal struct Headers {
    static let acceptLanguageKey = "Accept-Language"
    static let acceptLanguageValue = "en-US"
    static let igCapabilitiesKey = "X-IG-Capabilities"
    static let igCapabilitiesValue = "3brTvw=="
    static let igConnectionTypeKey = "X-IG-Connection-Type"
    static let igConnectionTypeValue = "WIFI"
    static let xGoogleAdId = "X-Google-AD-ID"
    static let userAgentKey = "User-Agent"
    static let userAgentValue = "Instagram 85.0.0.21.100 Android (21/5.0.2; 640dpi; 1440x2560; Sony; C6603; C6603; qcom; en_US; 95414346)"
    static let contentTypeKey = "Content-Type"
    static let contentTypeApplicationFormValue = "application/x-www-form-urlencoded"
    static let igSignatureKey = "signed_body"
    static let igSignatureValue = "937463b5272b5d60e9d20f0f8d7d192193dd95095a3ad43725d494300a5ea5fc"
    static let igSignatureVersionKey = "ig_sig_key_version"
    static let igSignatureVersionValue = "5"
    static let timeZoneOffsetKey = "timezone_offset"
    static let timeZoneOffsetValue = "43200"
    static let countKey = "count"
    static let countValue = "1"
    static let rankTokenKey = "rank_token"
}
