//
//  HTTPCookie.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 29/10/20.
//

import Foundation

extension Collection where Element: HTTPCookie {
    /// Check wether the user is correctly authenticated or not.
    var containsAuthenticationCookies: Bool {
        Set(map(\.name)).intersection(["ds_user_id", "sessionid", "csrftoken"]).count == 3
    }
}
