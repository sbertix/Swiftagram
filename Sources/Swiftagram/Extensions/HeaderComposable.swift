//
//  HeaderComposable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 18/05/2020.
//

import Foundation

import ComposableRequest

/// Extend `HeaderComposable` to accept default headers.
public extension HeaderComposable where Self: HeaderParsable {
    /// Append default headers.
    /// - returns: `self` with updated header fields.
    func appendingDefaultHeader() -> Self {
        return appending(header: [
            "User-Agent": Client.default.description,
            "X-Ads-Opt-Out": "0",
            "X-CM-Bandwidth-KBPS": "-1.000",
            "X-CM-Latency": "-1.000",
            "X-IG-App-Locale": "en_US",
            "X-IG-Device-Locale": "en_US",
            "X-Pigeon-Session-Id": UUID().uuidString.lowercased(),
            "X-Pigeon-Rawclienttime": "\(Int(Date().timeIntervalSince1970)).000",
            "X-IG-Connection-Speed": "\(Int.random(in: 1000...3700))kbps",
            "X-IG-Bandwidth-Speed-KBPS": "-1.000",
            "X-IG-Bandwidth-TotalBytes-B": "0",
            "X-IG-Bandwidth-TotalTime-MS": "0",
            "X-IG-Extended-CDN-Thumbnail-Cache-Busting-Value": "1000",
            "X-Bloks-Version-Id": Constants.bloksVersionId.lowercased(),
            "X-IG-WWW-Claim": "0",
            "X-Bloks-Is-Layout-RTL": "false",
            "X-IG-Connection-Type": "WIFI",
            "X-IG-Capabilities": "36r/Fx8=",
            "X-IG-App-ID": "567067343352427",
            "X-IG-Device-ID": Client.default.device.identifier.uuidString.lowercased(),
            "X-IG-Android-ID": Client.default.device.instagramIdentifier,
            "Accept-Language": "en-US",
            "X-FB-HTTP-Engine": "Liger",
            "Host": "i.instagram.com",
            "Accept-Encoding": "gzip",
            "Connection": "close"
        ])
    }
}
