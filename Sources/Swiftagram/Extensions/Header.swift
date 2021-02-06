//
//  Header.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 18/05/2020.
//

import Foundation

import ComposableRequest

public extension Header {
    /// Append default headers.
    ///
    /// - returns: `self` with updated header fields.
    /// - note: Starting from `4.2.0`, `Client` related info is no longer added through this method.
    func appendingDefaultHeader() -> Self {
        header(appending: [
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
            "X-Bloks-Version-Id": "7b2216598d8fcf84fbda65652788cb12be5aa024c4ea5e03deeb2b81a383c9e0",
            "X-IG-WWW-Claim": "0",
            "X-Bloks-Is-Layout-RTL": "false",
            "X-IG-Connection-Type": "WIFI",
            "X-IG-Capabilities": "36r/Fx8=",
            "X-IG-App-ID": "567067343352427",
            "Accept-Language": "en-US",
            "X-FB-HTTP-Engine": "Liger",
            "Host": "i.instagram.com",
            "Accept-Encoding": "gzip",
            "Connection": "close"
        ])
    }
}
