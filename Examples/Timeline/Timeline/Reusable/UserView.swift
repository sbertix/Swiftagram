//
//  UserView.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import SwiftUI
import UIKit

import Nuke

/// A `struct` displaying a `User`.
struct UserView: View {
    /// A valid `User`.
    var user: User

    /// The actual body.
    var body: some View {
        HStack {
            // The image or a placeholder.
            if user.avatar != nil {
                user.avatar.flatMap {
                    RemoteImage(url: $0, placeholder: UIImage(named: "placeholder") ?? .init())
                        .frame(width: 30, height: 30)
                        .mask(Circle())
                        .shadow(radius: 1)
                }
            } else {
                SwiftUI.Image("placeholder")
                    .frame(width: 30, height: 30)
                    .mask(Circle())
                    .shadow(radius: 1)
            }
            // The username and name.
            VStack(alignment: .leading) {
                Text(user.username).font(.headline)
                if user.name != nil {
                    user.name.flatMap(Text.init)?.font(.footnote).foregroundColor(.secondary)
                }
            }
        }
    }
}
